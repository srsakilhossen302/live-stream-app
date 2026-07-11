import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/socket_service.dart';

class MessageDetailsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final chatId = ''.obs;
  final partnerName = 'User'.obs;
  final partnerAvatar = ''.obs;
  final partnerId = ''.obs;
  final isLoading = true.obs;

  final messages = <Map<String, dynamic>>[].obs;

  // Order info — only populated when this chat is linked to a real order
  final hasOrder = false.obs;
  final orderData = <String, dynamic>{}.obs;

  final chatInputController = TextEditingController();
  final scrollController = ScrollController();

  // Known message IDs — used to detect new messages from polling
  final Set<String> _knownMessageIds = {};
  // Track sent message IDs to suppress socket echo duplicates
  final Set<String> _sentMessageIds = {};

  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    chatId.value = args['chatId'] ?? '';
    partnerName.value = args['name'] ?? 'User';
    partnerAvatar.value = args['avatar'] ?? '';
    partnerId.value = args['participantId'] ?? '';

    // Populate order info if passed from a purchase flow
    final order = args['order'];
    if (order != null && order is Map) {
      orderData.value = Map<String, dynamic>.from(order);
      hasOrder.value = true;
    }

    if (chatId.value.isNotEmpty) {
      fetchMessages(); // initial full load
      _setupSocketListener();
      _startPolling(); // fallback polling every 3s
    } else {
      _loadMockMessages();
    }
  }

  // ─── SOCKET ────────────────────────────────────────────────────────────────

  void _setupSocketListener() {
    try {
      final socketService = Get.find<SocketService>();
      socketService.joinChat(chatId.value);
      socketService.on('messageReceived', _onSocketMessage);
      socketService.on('newMessage', _onSocketMessage);
      socketService.on('new message', _onSocketMessage);
      socketService.initSocket();
      Get.log('🔧 [MessageCtrl] Socket ready for room: ${chatId.value}');
    } catch (e) {
      Get.log('❌ [MessageCtrl] Socket setup error: $e');
    }
  }

  void _onSocketMessage(dynamic data) {
    Get.log('📩 [Socket] Raw: $data');
    if (data == null) return;
    try {
      Map<String, dynamic> msgMap;
      if (data is String) {
        msgMap = Map<String, dynamic>.from(jsonDecode(data));
      } else if (data is Map) {
        msgMap = Map<String, dynamic>.from(data);
      } else {
        return;
      }

      final String text = msgMap['text'] ?? msgMap['message'] ?? '';
      if (text.isEmpty) return;

      // Only for this chat room
      final String incomingChat = msgMap['chatId'] ?? '';
      if (incomingChat.isNotEmpty && incomingChat != chatId.value) return;

      final senderId = msgMap['senderId'] ?? msgMap['sender'] ?? '';
      final currentUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
      bool isMe = false;
      if (senderId is String) {
        isMe = senderId == currentUserId;
      } else if (senderId is Map) {
        isMe = senderId['_id'] == currentUserId || senderId['id'] == currentUserId;
      }

      final String msgId = msgMap['_id'] ?? msgMap['id'] ?? '';

      // If it's my own sent message, update the optimistic bubble instead of adding new
      if (isMe) {
        final idx = messages.indexWhere(
            (m) => m['isMe'] == true && m['message'] == text && m['time'] == 'Now');
        if (idx != -1) {
          messages[idx] = {
            '_id': msgId,
            'isMe': true,
            'message': text,
            'time': _formatTime(msgMap['createdAt'] ?? ''),
            'isRead': msgMap['isRead'] == true,
          };
          messages.refresh();
          if (msgId.isNotEmpty) _knownMessageIds.add(msgId);
          return;
        }
      }

      // Skip if already known
      if (msgId.isNotEmpty && _knownMessageIds.contains(msgId)) return;
      if (msgId.isNotEmpty) _knownMessageIds.add(msgId);

      // Add at BOTTOM
      messages.add({
        '_id': msgId,
        'isMe': isMe,
        'message': text,
        'time': _formatTime(msgMap['createdAt'] ?? ''),
        'isRead': msgMap['isRead'] == true,
      });
      _scrollToBottom();
    } catch (e) {
      Get.log('❌ [Socket] Parse error: $e');
    }
  }

  // ─── POLLING FALLBACK ───────────────────────────────────────────────────────

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (chatId.value.isEmpty || chatId.value.startsWith('mock_')) return;
      await _pollNewMessages();
    });
  }

  Future<void> _pollNewMessages() async {
    try {
      final response = await _apiClient.getData('${ApiUrl.message}/${chatId.value}');
      if (response.statusCode != 200) return;

      final List data = jsonDecode(response.body)['data'] ?? [];
      if (data.isEmpty) return;

      final currentUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
      bool hasNew = false;

      for (var msg in data) {
        final String msgId = msg['_id'] ?? msg['id'] ?? '';
        if (msgId.isEmpty || _knownMessageIds.contains(msgId)) continue;

        // This is a new message not yet in our list
        _knownMessageIds.add(msgId);
        hasNew = true;

        final sender = msg['senderId'] ?? msg['sender'];
        final isMe = sender == currentUserId ||
            (sender is Map &&
                (sender['_id'] == currentUserId || sender['id'] == currentUserId));

        // If it's my optimistic bubble, update it
        final String text = msg['text'] ?? '';
        if (isMe) {
          final idx = messages.indexWhere(
              (m) => m['isMe'] == true && m['message'] == text && m['time'] == 'Now');
          if (idx != -1) {
            messages[idx] = {
              '_id': msgId,
              'isMe': true,
              'message': text,
              'time': _formatTime(msg['createdAt'] ?? ''),
              'isRead': msg['isRead'] == true,
            };
            messages.refresh();
            continue;
          }
        }

        // Add new message at BOTTOM
        messages.add({
          '_id': msgId,
          'isMe': isMe,
          'message': text,
          'time': _formatTime(msg['createdAt'] ?? ''),
          'isRead': msg['isRead'] == true,
        });
      }

      if (hasNew) _scrollToBottom();
    } catch (e) {
      // Silently ignore polling errors
    }
  }

  // ─── FETCH (initial full load) ──────────────────────────────────────────────

  Future<void> fetchMessages() async {
    isLoading.value = true;
    try {
      if (chatId.value.startsWith('mock_')) {
        _loadMockMessages();
        return;
      }

      final response = await _apiClient.getData('${ApiUrl.message}/${chatId.value}');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        final List<Map<String, dynamic>> parsedList = [];
        _knownMessageIds.clear();

        if (data.isNotEmpty) {
          parsedList.add({'isDate': true, 'message': 'TODAY'});
        }

        final currentUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);

        for (var msg in data) {
          final String msgId = msg['_id'] ?? msg['id'] ?? '';
          if (msgId.isNotEmpty) _knownMessageIds.add(msgId);

          final sender = msg['senderId'] ?? msg['sender'];
          final isMe = sender == currentUserId ||
              (sender is Map &&
                  (sender['_id'] == currentUserId || sender['id'] == currentUserId));

          parsedList.add({
            '_id': msgId,
            'isMe': isMe,
            'message': msg['text'] ?? '',
            'time': _formatTime(msg['createdAt'] ?? ''),
            'isRead': msg['isRead'] == true,
          });
        }

        // Oldest first → newest at BOTTOM
        messages.assignAll(parsedList);
      } else {
        _loadMockMessages();
      }
    } catch (e) {
      Get.log('❌ [MessageCtrl] fetchMessages error: $e');
      _loadMockMessages();
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  // ─── MOCK ───────────────────────────────────────────────────────────────────

  void _loadMockMessages() {
    messages.assignAll([
      {'isDate': true, 'message': 'YESTERDAY'},
      {
        'isMe': false,
        'message': "Hey! I just saw your bid win. I'll get the pack ready for shipping first thing tomorrow morning.",
        'time': '10:42 PM',
      },
      {
        'isMe': true,
        'message': "Perfect, thanks! Please ensure it's packed in a hard sleeve. It's for my personal vault.",
        'time': '10:45 PM',
        'isRead': true,
      },
      {'isDate': true, 'message': 'TODAY'},
      {
        'isMe': false,
        'message': "Just dropped it off! Tracking should update in a few hours.",
        'time': '11:15 AM',
      },
      {
        'isMe': true,
        'message': "That's awesome. Truly appreciate the extra care!",
        'time': '11:20 AM',
        'isRead': true,
      },
    ]);
    isLoading.value = false;
    _scrollToBottom();
  }

  // ─── SEND ───────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final msgText = text.trim();

    // Optimistic bubble — appears immediately on the RIGHT (isMe: true)
    messages.add({
      'isMe': true,
      'message': msgText,
      'time': 'Now',
      'isRead': false,
    });
    chatInputController.clear();
    _scrollToBottom();

    try {
      if (chatId.value.isEmpty || chatId.value.startsWith('mock_')) {
        _runMockReply();
        return;
      }

      final response = await _apiClient.postData(ApiUrl.message, {
        'chatId': chatId.value,
        'text': msgText,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = jsonDecode(response.body);
        final messageData = resBody['data'];
        if (messageData != null) {
          final msgId = messageData['_id'] ?? messageData['id'] ?? '';
          if (msgId.isNotEmpty) {
            _sentMessageIds.add(msgId);
            _knownMessageIds.add(msgId); // prevent polling from re-adding
          }
          // Emit to socket so the OTHER user gets it instantly
          try {
            final socketService = Get.find<SocketService>();
            socketService.emitEvent('new message', messageData);
          } catch (e) {
            Get.log('❌ [MessageCtrl] Socket emit error: $e');
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to send message');
      }
    } catch (e) {
      Get.log('❌ [MessageCtrl] sendMessage error: $e');
    }
  }

  void _runMockReply() {
    Future.delayed(const Duration(seconds: 1), () {
      messages.add({
        'isMe': false,
        'message': "Got it! Let me know if there's anything else. Enjoy your cards! 🎴✨",
        'time': 'Now',
      });
      _scrollToBottom();
    });
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return 'Now';
    try {
      final parsed = DateTime.parse(timeStr).toLocal();
      return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Now';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── LIFECYCLE ──────────────────────────────────────────────────────────────

  @override
  void onClose() {
    _pollingTimer?.cancel();
    if (chatId.value.isNotEmpty) {
      try {
        final socketService = Get.find<SocketService>();
        socketService.leaveChat(chatId.value);
        socketService.off('messageReceived');
        socketService.off('newMessage');
        socketService.off('new message');
      } catch (e) {
        Get.log('❌ [MessageCtrl] onClose cleanup error: $e');
      }
    }
    chatInputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
