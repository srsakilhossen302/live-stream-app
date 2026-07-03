import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/socket_service.dart';

class MessageDetailsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final chatId = "".obs;
  final partnerName = "User".obs;
  final partnerAvatar = "".obs;
  final isLoading = true.obs;

  final messages = <Map<String, dynamic>>[].obs;

  final chatInputController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    chatId.value = args['chatId'] ?? '';
    partnerName.value = args['name'] ?? 'User';
    partnerAvatar.value = args['avatar'] ?? '';
    
    // Ensure socket is initialized
    try {
      final socketService = Get.find<SocketService>();
      if (socketService.socket == null || !socketService.isConnected.value) {
        socketService.initSocket();
      }
    } catch (e) {
      Get.log("Could not auto-initialize socket in message details: $e");
    }

    if (chatId.value.isNotEmpty) {
      fetchMessages();
      _setupSocketListener();
    } else {
      _loadMockMessages();
    }
  }

  void _setupSocketListener() {
    try {
      final socketService = Get.find<SocketService>();
      
      // Join chat room
      socketService.joinChat(chatId.value);
      
      // Listen to events
      socketService.socket?.on('messageReceived', _onMessageReceived);
      socketService.socket?.on('newMessage', _onMessageReceived);
      socketService.socket?.on('message', _onMessageReceived);
    } catch (e) {
      Get.log("Error setting up socket listener: $e");
    }
  }

  void _onMessageReceived(dynamic data) {
    Get.log("📩 [Socket] Message received: $data");
    if (data == null) return;

    try {
      Map<String, dynamic> msgMap;
      if (data is String) {
        msgMap = Map<String, dynamic>.from(jsonDecode(data));
      } else {
        msgMap = Map<String, dynamic>.from(data);
      }

      final String text = msgMap['text'] ?? msgMap['message'] ?? '';
      if (text.isEmpty) return;

      final senderId = msgMap['senderId'] ?? msgMap['sender'] ?? '';
      final currentUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);

      bool isMe = false;
      if (senderId is String) {
        isMe = senderId == currentUserId;
      } else if (senderId is Map) {
        isMe = senderId['_id'] == currentUserId || senderId['id'] == currentUserId;
      }

      // Verify if it is for the current chat room
      final String incomingChatId = msgMap['chatId'] ?? '';
      if (incomingChatId.isNotEmpty && incomingChatId != chatId.value) {
        Get.log("ℹ️ [Socket] Message is for another room ($incomingChatId), ignored.");
        return;
      }

      final formattedTime = _formatTime(msgMap['createdAt'] ?? '');

      // Check if message already exists to avoid duplicates or update 'Now' state
      int index = -1;
      if (isMe) {
        index = messages.indexWhere((msg) => msg['isMe'] == true && msg['message'] == text && (msg['time'] == 'Now' || msg['time'] == formattedTime));
      } else {
        index = messages.indexWhere((msg) => msg['message'] == text && msg['time'] == formattedTime);
      }

      if (index != -1) {
        messages[index] = {
          "isMe": isMe,
          "message": text,
          "time": formattedTime,
          "isRead": msgMap['isRead'] == true,
        };
        messages.refresh();
        Get.log("ℹ️ [Socket] Updated existing message timestamp/read status.");
        return;
      }

      // Add to list
      messages.add({
        "isMe": isMe,
        "message": text,
        "time": formattedTime,
        "isRead": msgMap['isRead'] == true,
      });

      _scrollToBottom();
    } catch (e) {
      Get.log("❌ [Socket] Error parsing message: $e");
    }
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    try {
      if (chatId.value.startsWith("mock_")) {
        _loadMockMessages();
        return;
      }

      final response = await _apiClient.getData("${ApiUrl.message}/${chatId.value}");
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        final List<Map<String, dynamic>> parsedList = [];
        
        // Add date separator if we have messages
        if (data.isNotEmpty) {
          parsedList.add({
            "isDate": true,
            "message": "TODAY",
          });
        }

        for (var msg in data) {
          final sender = msg['senderId'];
          final isMe = sender == SharePrefsHelper.getString(SharePrefsHelper.userIdKey) || 
                       (sender is Map && sender['_id'] == SharePrefsHelper.getString(SharePrefsHelper.userIdKey));
          
          parsedList.add({
            "isMe": isMe,
            "message": msg['text'] ?? "",
            "time": _formatTime(msg['createdAt']),
          });
        }
        messages.assignAll(parsedList);
      } else {
        _loadMockMessages();
      }
    } catch (e) {
      Get.log("Error fetching messages: $e");
      _loadMockMessages();
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _loadMockMessages() {
    messages.assignAll([
      {
        "isDate": true,
        "message": "YESTERDAY",
      },
      {
        "isMe": false,
        "message": "Hey! I just saw your bid win. I'll get the pack ready for shipping first thing tomorrow morning.",
        "time": "10:42 PM",
      },
      {
        "isMe": true,
        "message": "Perfect, thanks! Please ensure it's packed in a hard sleeve. It's for my personal vault.",
        "time": "10:45 PM",
        "isRead": true,
      },
      {
        "isDate": true,
        "message": "TODAY",
      },
      {
        "isMe": false,
        "message": "Just dropped it off! Tracking should update in a few hours. I used a double-layered bubble mailer plus the hard sleeve as requested.",
        "time": "11:15 AM",
      },
      {
        "isMe": true,
        "message": "That's awesome. Truly appreciate the extra care with the packaging. I'll keep an eye out!",
        "time": "11:20 AM",
        "isRead": true,
      },
    ]);
    isLoading.value = false;
    _scrollToBottom();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final msgText = text.trim();

    messages.add({
      "isMe": true,
      "message": msgText,
      "time": "Now",
      "isRead": false,
    });
    chatInputController.clear();
    _scrollToBottom();

    try {
      if (chatId.value.isEmpty || chatId.value.startsWith("mock_")) {
        _runMockReply();
        return;
      }

      final response = await _apiClient.postData(ApiUrl.message, {
        "chatId": chatId.value,
        "text": msgText,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        Get.snackbar("Error", "Failed to send message");
      }
    } catch (e) {
      Get.log("Error sending message: $e");
    }
  }

  void _runMockReply() {
    Future.delayed(const Duration(seconds: 1), () {
      messages.add({
        "isMe": false,
        "message": "Got it! Let me know if there's anything else you need. Enjoy your cards! 🎴✨",
        "time": "Now",
      });
      _scrollToBottom();
    });
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return "Now";
    try {
      final parsed = DateTime.parse(timeStr).toLocal();
      return "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "Now";
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

  @override
  void onClose() {
    if (chatId.value.isNotEmpty) {
      try {
        final socketService = Get.find<SocketService>();
        socketService.leaveChat(chatId.value);
        socketService.socket?.off('messageReceived', _onMessageReceived);
        socketService.socket?.off('newMessage', _onMessageReceived);
        socketService.socket?.off('message', _onMessageReceived);
      } catch (e) {
        Get.log("Error leaving socket room on close: $e");
      }
    }
    chatInputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
