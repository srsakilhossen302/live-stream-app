import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../../../../data/services/socket_service.dart';
import '../../profile/controller/profile_controller.dart';

class FloatingHeart {
  final double id;
  final double scale;
  final double angle;
  final Color color;
  FloatingHeart({
    required this.id,
    required this.scale,
    required this.angle,
    required this.color,
  });
}

/// IMPORTANT: Replace with your Agora App ID from https://console.agora.io
const String agoraAppId = "040148b3e0a14154bc4eb74663dabf5f";

class AgoraLiveController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  RtcEngine? engine;

  // Host info
  final RxString streamId = "".obs;
  final RxString channelName = "".obs;
  final RxString streamTitle = "".obs;
  final RxString streamDescription = "".obs;

  // Auction / product
  final RxString auctionItemId = "".obs;
  final RxString currentProductTitle = "".obs;
  final RxString currentProductImage = "".obs;
  final RxDouble currentBidPrice = 0.0.obs;
  final RxInt bidTimer = 60.obs;
  final RxBool auctionActive = false.obs;
  
  final RxString lastBidderId = "".obs;
  final RxString lastBidderName = "".obs;
  final RxBool isCalculatingResult = false.obs;
  final RxBool showWinnerOverlay = false.obs;
  final RxBool timerExtendedNotification = false.obs;
  Timer? _countdownTimer;

  // Stream state
  final RxBool isLive = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCameraOn = true.obs;
  final RxBool isMicOn = true.obs;
  final RxBool isLocalVideoReady = false.obs;

  // Viewer state
  final RxInt remoteUid = (-1).obs;
  final RxBool remoteJoined = false.obs;

  // Bid
  final RxString customBid = "".obs;
  final RxBool isLiked = false.obs;

  // Live streams list (for Discover)
  final RxList<Map<String, dynamic>> liveStreamsList = <Map<String, dynamic>>[].obs;
  final RxBool loadingStreams = false.obs;

  // Messages / chat
  final RxList<Map<String, String>> chatMessages = <Map<String, String>>[].obs;

  // Dynamic data stream parameters
  int? _dataStreamId;
  final RxInt likeCount = 1200.obs;
  final RxList<FloatingHeart> floatingHearts = <FloatingHeart>[].obs;

  void triggerFloatingHeart() {
    final double id = DateTime.now().microsecondsSinceEpoch.toDouble();
    final colors = [
      const Color(0xFFFF528E),
      const Color(0xFFFF52C5),
      const Color(0xFFFF8B52),
      const Color(0xFFFF5252),
      Colors.redAccent,
    ];
    final randomColor = colors[id.toInt() % colors.length];
    final randomAngle = (id.toInt() % 40 - 20) * (3.14159 / 180); // random angle between -20 and 20 degrees
    final randomScale = 0.8 + (id.toInt() % 5) * 0.1; // scale between 0.8 and 1.2
    
    final heart = FloatingHeart(
      id: id,
      scale: randomScale,
      angle: randomAngle,
      color: randomColor,
    );
    
    floatingHearts.add(heart);
    
    // Auto remove after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      floatingHearts.removeWhere((h) => h.id == id);
    });
  }

  @override
  void onInit() {
    super.onInit();
    fetchLiveStreams();
  }

  // ─────────────────────────────────────────────
  //  FETCH LIVE STREAMS (Discover page)
  // ─────────────────────────────────────────────
  Future<void> fetchLiveStreams() async {
    loadingStreams.value = true;
    try {
      final res = await _apiClient.getData("${ApiUrl.liveStreams}?status=live");
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = body['data'] ?? body['streams'] ?? body['result'] ?? [];
        if (data is List) {
          liveStreamsList.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
        }
      }
    } catch (e) {
      debugPrint("fetchLiveStreams error: $e");
    } finally {
      loadingStreams.value = false;
    }
  }

  // ─── SOCKET LISTENERS ─────────────────────────
  void _setupSocket() {
    try {
      final socketService = Get.find<SocketService>();
      socketService.initSocket();
      socketService.joinChat(streamId.value);
      
      socketService.on('messageReceived', _handleSocketMessage);
      socketService.on('newMessage', _handleSocketMessage);
      socketService.on('new message', _handleSocketMessage);
      socketService.on('message received', _handleSocketMessage);
      
      debugPrint("🔌 [AgoraLiveSocket] Joined stream room: ${streamId.value}");
    } catch (e) {
      debugPrint("❌ [AgoraLiveSocket] Setup error: $e");
    }
  }

  void broadcastJoin() {
    String usernameStr = "Viewer";
    String avatarUrl = "";
    try {
      final profileCtrl = Get.find<ProfileController>();
      usernameStr = profileCtrl.name.value;
      avatarUrl = profileCtrl.profileImageUrl.value;
    } catch (_) {}

    try {
      final socketService = Get.find<SocketService>();
      socketService.emitEvent('new message', {
        "chat": streamId.value,
        "chatId": streamId.value,
        "content": "$usernameStr joined this stream",
        "text": "$usernameStr joined this stream",
        "message": "$usernameStr joined this stream",
        "sender": {
          "_id": SharePrefsHelper.getString(SharePrefsHelper.userIdKey),
          "fullName": usernameStr,
          "name": usernameStr,
          "avatar": avatarUrl,
        },
        "senderId": SharePrefsHelper.getString(SharePrefsHelper.userIdKey),
        "userAvatar": avatarUrl,
        "isJoinEvent": true,
        "isLiveStream": true,
      });
    } catch (_) {}

    // Broadcast join via Data Stream (Agora fallback)
    if (engine != null && _dataStreamId != null) {
      try {
        final payload = jsonEncode({
          "type": "join",
          "username": usernameStr,
          "avatar": avatarUrl,
        });
        final bytes = utf8.encode(payload);
        engine!.sendStreamMessage(
          streamId: _dataStreamId!,
          data: Uint8List.fromList(bytes),
          length: bytes.length,
        );
        debugPrint("✅ Broadcasted join via Agora: $payload");
      } catch (_) {}
    }
  }

  void _cleanupSocket() {
    try {
      final socketService = Get.find<SocketService>();
      socketService.leaveChat(streamId.value);
      socketService.off('messageReceived', _handleSocketMessage);
      socketService.off('newMessage', _handleSocketMessage);
      socketService.off('new message', _handleSocketMessage);
      socketService.off('message received', _handleSocketMessage);
      debugPrint("🔌 [AgoraLiveSocket] Left stream room: ${streamId.value}");
    } catch (e) {
      debugPrint("❌ [AgoraLiveSocket] Cleanup error: $e");
    }
  }

  void _handleSocketMessage(dynamic data) {
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

      // Verify the chat ID maps to our active stream ID
      final String incomingChat = (msgMap['chat'] is Map)
          ? (msgMap['chat']['_id'] ?? msgMap['chat']['id'] ?? '')
          : (msgMap['chat'] ?? msgMap['chatId'] ?? '');
      if (incomingChat.isEmpty || incomingChat != streamId.value) return;

      final content = msgMap['content'] ?? msgMap['message'] ?? msgMap['text'] ?? '';
      if (content.isEmpty) return;

      final sender = msgMap['sender'];
      final senderName = sender is Map
          ? (sender['fullName'] ?? sender['name'] ?? 'User')
          : 'User';
      final senderId = sender is Map
          ? (sender['_id'] ?? sender['id'] ?? '')
          : (msgMap['senderId'] ?? '');
      final senderAvatar = sender is Map
          ? (sender['avatar'] ?? sender['profile'] ?? sender['image'] ?? '')
          : (msgMap['userAvatar'] ?? '');

      final currentUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
      if (senderId == currentUserId) {
        // Skip duplicate of self-added local message
        return;
      }

      // Handle Extend Timer event
      if (msgMap['isExtendTimer'] == true) {
        extendTimerLocal();
      }

      // Handle New Auction starting event
      if (msgMap['isNewAuction'] == true) {
        auctionItemId.value = msgMap['auctionItemId']?.toString() ?? '';
        currentProductTitle.value = msgMap['productTitle']?.toString() ?? 'Product';
        currentProductImage.value = msgMap['productImage']?.toString() ?? '';
        currentBidPrice.value = double.tryParse(msgMap['startingBid']?.toString() ?? '0') ?? 0.0;
        lastBidderId.value = "";
        lastBidderName.value = "";
        showWinnerOverlay.value = false;
        auctionActive.value = true;
        
        final duration = int.tryParse(msgMap['timerDuration']?.toString() ?? '60') ?? 60;
        startCountdown(duration);
        
        chatMessages.add({
          "user": "System",
          "msg": "📢 Starting a new auction for ${currentProductTitle.value}!",
          "role": "system",
          "isJoin": "false",
          "userAvatar": "",
        });
        return;
      }

      // Handle Like event
      final isLike = msgMap['isLike'] == true || content.toString().contains('❤️');
      if (isLike) {
        likeCount.value++;
        triggerFloatingHeart(); // Spawn floating heart
        debugPrint("❤️ Dynamic Like count received via socket: ${likeCount.value}");
        return;
      }

      final isJoin = msgMap['isJoinEvent'] == true || content.toString().contains('joined this stream');
      final isBid = msgMap['isBid'] == true || content.toString().contains('🔨 Placed bid:');
      final bidAmount = double.tryParse(msgMap['bidAmount']?.toString() ?? '0') ?? 0.0;
      final role = msgMap['role'] ?? (isJoin ? 'system' : 'viewer');

      if (isBid && bidAmount > 0) {
        lastBidderId.value = senderId;
        lastBidderName.value = senderName.replaceAll('@', '');
        if (bidAmount > currentBidPrice.value) {
          currentBidPrice.value = bidAmount;
        }
      }

      chatMessages.add({
        "user": senderName.toString().startsWith('@') ? senderName.toString() : '@$senderName',
        "msg": isJoin ? "joined this stream" : content.toString(),
        "role": role.toString(),
        "isBid": isBid ? "true" : "false",
        "userAvatar": senderAvatar.toString(),
        "isJoin": isJoin ? "true" : "false",
      });
      debugPrint("📩 [AgoraLiveSocket] Received: $content from $senderName");
    } catch (e) {
      debugPrint("❌ [AgoraLiveSocket] Parse error: $e");
    }
  }

  void startCountdown(int duration) {
    _countdownTimer?.cancel();
    bidTimer.value = duration;
    showWinnerOverlay.value = false;
    isCalculatingResult.value = false;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!auctionActive.value) {
        timer.cancel();
        return;
      }
      if (bidTimer.value > 0) {
        bidTimer.value--;
      } else {
        timer.cancel();
        _handleAuctionTimeout();
      }
    });
  }

  void extendTimerLocal() {
    bidTimer.value = (bidTimer.value + 10).clamp(0, 20);
    timerExtendedNotification.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      timerExtendedNotification.value = false;
    });
    chatMessages.add({
      "user": "System",
      "msg": "🔥 Bid received in last 10s! Extended by 10s.",
      "role": "system",
      "isJoin": "false",
      "userAvatar": "",
    });
  }

  Future<void> _handleAuctionTimeout() async {
    isCalculatingResult.value = true;
    auctionActive.value = false; // Disable bidding
    
    await Future.delayed(const Duration(milliseconds: 2500));
    
    isCalculatingResult.value = false;
    showWinnerOverlay.value = true;
    debugPrint("🏆 Auction Ended. Winner: ${lastBidderName.value} ($currentBidPrice)");
  }

  // ─────────────────────────────────────────────
  //  START STREAM (Host)
  // ─────────────────────────────────────────────
  Future<bool> startStream({
    required String title,
    required String description,
    required String productId,
    required double startingBid,
    required int timerDuration,
    String productTitle = "",
    String productImage = "",
  }) async {
    isLoading.value = true;
    try {
      final sellerId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey) ?? "";
      final channel = "stream_${sellerId}_${DateTime.now().millisecondsSinceEpoch}";

      currentProductTitle.value = productTitle;
      currentProductImage.value = productImage;

      // 1) Create stream on backend
      final streamRes = await _apiClient.postData(ApiUrl.startStream, {
        "title": title,
        "description": description,
        "sellerId": sellerId,
        "agoraChannelName": channel,
        "status": "live",
      });

      if (streamRes.statusCode != 200 && streamRes.statusCode != 201) {
        final errBody = jsonDecode(streamRes.body);
        final errMsg = errBody['message'] ?? "Failed to create stream (${streamRes.statusCode})";
        Get.snackbar("Error", errMsg,
            backgroundColor: Colors.red.withValues(alpha: 0.85),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      final streamBody = jsonDecode(streamRes.body);
      final sid = streamBody['data']?['_id'] ?? streamBody['_id'] ?? "";
      streamId.value = sid;
      channelName.value = channel;
      streamTitle.value = title;
      streamDescription.value = description;

      // Initialize Socket for Host
      _setupSocket();

      // 2) Add auction item to the stream
      if (productId.isNotEmpty && sid.isNotEmpty) {
        final itemRes = await _apiClient.postData(ApiUrl.addAuctionItem, {
          "streamId": sid,
          "productId": productId,
          "startingBid": startingBid,
          "bidIncrement": 100,
          "timerDuration": timerDuration,
        });
        if (itemRes.statusCode == 200 || itemRes.statusCode == 201) {
          final itemBody = jsonDecode(itemRes.body);
          auctionItemId.value = itemBody['data']?['_id'] ?? "";
          currentBidPrice.value = startingBid;
          lastBidderId.value = "";
          lastBidderName.value = "";
          showWinnerOverlay.value = false;
          auctionActive.value = true;
          startCountdown(timerDuration);
        }
      }

      // 3) Initialize Agora as HOST
      final agoraOk = await _initAgora(isHost: true, channel: channel);
      debugPrint(agoraOk ? "✅ Agora ready" : "⚠️ Agora failed — stream will run in backend-only mode");
      isLive.value = true;  // Always go live — camera may not be available
      return true;
    } catch (e) {
      Get.snackbar("Error", "Stream error: $e", snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  JOIN AS VIEWER
  // ─────────────────────────────────────────────
  Future<void> joinAsViewer(Map<String, dynamic> streamData) async {
    isLoading.value = true;
    try {
      final sid = streamData['_id']?.toString() ?? "";
      streamId.value = sid;
      streamTitle.value = streamData['title']?.toString() ?? "Live Stream";

      // 1) Fetch fresh stream list to get latest populated auction items!
      Map<String, dynamic> activeStream = streamData;
      try {
        final res = await _apiClient.getData("${ApiUrl.liveStreams}?status=live");
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          final data = body['data'] ?? body['streams'] ?? body['result'] ?? [];
          if (data is List) {
            final freshStream = data.firstWhere(
              (element) => element['_id']?.toString() == sid,
              orElse: () => null,
            );
            if (freshStream != null) {
              activeStream = Map<String, dynamic>.from(freshStream);
              debugPrint("✅ Fetched fresh stream data: $activeStream");
            }
          }
        }
      } catch (e) {
        debugPrint("⚠️ Failed to fetch fresh stream list: $e");
      }

      final channel = activeStream['agoraChannelName']?.toString() ?? "";
      channelName.value = channel;

      // Initialize Socket for Viewer
      _setupSocket();

      // 2) Parse product info if available
      final items = activeStream['auctionItems'];
      if (items is List && items.isNotEmpty) {
        final item = items[0];
        
        // Populate product title and image safely
        final prod = item['productId'];
        if (prod is Map) {
          currentProductTitle.value = prod['title']?.toString() ?? "Product";
          final images = prod['images'];
          if (images is List && images.isNotEmpty) {
            currentProductImage.value = images[0]?.toString() ?? "";
          }
        } else {
          currentProductTitle.value = "Product";
        }
        
        currentBidPrice.value = double.tryParse(item['currentBid']?.toString() ?? item['startingBid']?.toString() ?? "0") ?? 0;
        auctionItemId.value = item['_id']?.toString() ?? "";
        lastBidderId.value = item['highestBidder']?.toString() ?? "";
        lastBidderName.value = ""; // unknown initially
        showWinnerOverlay.value = false;
        auctionActive.value = true;
        
        final duration = int.tryParse(item['timerDuration']?.toString() ?? "60") ?? 60;
        startCountdown(duration);
        debugPrint("✅ Parsed Auction Item: ${auctionItemId.value} | Price: ${currentBidPrice.value} | Duration: $duration");
      } else {
        debugPrint("⚠️ No auction items found in stream!");
      }

      final agoraOk = await _initAgora(isHost: false, channel: channel);
      debugPrint(agoraOk ? "✅ Agora viewer ready" : "⚠️ Agora failed — viewing in backend-only mode");
      isLive.value = true;

      // Trigger join notification broadcast
      broadcastJoin();
    } catch (e) {
      Get.snackbar("Error", "Failed to join stream: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  PLACE BID
  // ─────────────────────────────────────────────
  Future<void> placeBid(double amount) async {
    debugPrint("placeBid called: amount=$amount, auctionItemId='${auctionItemId.value}', currentBidPrice='${currentBidPrice.value}'");
    if (auctionItemId.value.isEmpty) {
      Get.snackbar(
        "Bid Failed", 
        "No active auction item found for this stream. Please wait for the host to list an item.", 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.85),
        colorText: Colors.white,
      );
      return;
    }
    if (amount <= currentBidPrice.value) {
      Get.snackbar("Invalid Bid", "Bid must be higher than \$${currentBidPrice.value.toStringAsFixed(0)}", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final bidderId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey) ?? "";
      final res = await _apiClient.postData(ApiUrl.placeBid, {
        "auctionItemId": auctionItemId.value,
        "bidderId": bidderId,
        "bidAmount": amount,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        currentBidPrice.value = amount;
        
        String usernameStr = "@username";
        String avatarUrl = "";
        try {
          final profileCtrl = Get.find<ProfileController>();
          usernameStr = profileCtrl.username.value;
          avatarUrl = profileCtrl.profileImageUrl.value;
        } catch (_) {}

        lastBidderId.value = bidderId;
        lastBidderName.value = usernameStr.replaceAll('@', '');

        final msgText = "🔨 Placed bid: \$${amount.toStringAsFixed(0)}";

        // Add message locally
        chatMessages.add({
          "user": usernameStr.startsWith('@') ? usernameStr : '@$usernameStr',
          "msg": msgText,
          "isBid": "true",
          "userAvatar": avatarUrl,
        });
        Get.back(); // close bid sheet
        Get.snackbar("Bid Placed!", "Your bid of \$${amount.toStringAsFixed(0)} is live!", snackPosition: SnackPosition.BOTTOM);

        // Check Anti-Sniping
        bool extended = false;
        if (bidTimer.value <= 10) {
          extended = true;
          extendTimerLocal();
        }

        // Broadcast bid via Socket.io
        try {
          final socketService = Get.find<SocketService>();
          socketService.emitEvent('new message', {
            "chat": streamId.value,
            "chatId": streamId.value,
            "content": msgText,
            "text": msgText,
            "message": msgText,
            "sender": {
              "_id": bidderId,
              "fullName": usernameStr,
              "name": usernameStr,
              "avatar": avatarUrl,
            },
            "senderId": bidderId,
            "userAvatar": avatarUrl,
            "role": "viewer",
            "isBid": true,
            "bidAmount": amount,
            "isExtendTimer": extended,
            "isLiveStream": true,
          });
        } catch (e) {
          debugPrint("❌ Failed to broadcast bid via socket: $e");
        }

        // Broadcast bid via Data Stream (agora fallback)
        if (engine != null && _dataStreamId != null) {
          try {
            final payload = jsonEncode({
              "type": "bid",
              "username": usernameStr,
              "amount": amount,
              "avatar": avatarUrl,
              "senderId": bidderId,
              "extendTimer": extended,
            });
            final bytes = utf8.encode(payload);
            await engine!.sendStreamMessage(
              streamId: _dataStreamId!,
              data: Uint8List.fromList(bytes),
              length: bytes.length,
            );
            debugPrint("✅ Broadcasted bid via Agora");
          } catch (e) {
            debugPrint("❌ Failed to broadcast bid via Agora: $e");
          }
        }
      } else {
        final body = jsonDecode(res.body);
        Get.snackbar("Error", body['message'] ?? "Bid failed", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Bid error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> sendChatMessage(String msg, {required String role}) async {
    if (msg.trim().isEmpty) return;
    final cleanMsg = msg.trim();
    
    // Get sender username from ProfileController
    String usernameStr = "@username";
    String avatarUrl = "";
    try {
      final profileCtrl = Get.find<ProfileController>();
      usernameStr = profileCtrl.username.value;
      avatarUrl = profileCtrl.profileImageUrl.value;
    } catch (_) {}

    // Add message locally
    chatMessages.add({
      "user": usernameStr.startsWith('@') ? usernameStr : '@$usernameStr',
      "msg": cleanMsg,
      "role": role,
      "userAvatar": avatarUrl,
    });

    // Broadcast message via Socket.io
    try {
      final socketService = Get.find<SocketService>();
      final myUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
      socketService.emitEvent('new message', {
        "chat": streamId.value,
        "chatId": streamId.value,
        "content": cleanMsg,
        "text": cleanMsg,
        "message": cleanMsg,
        "sender": {
          "_id": myUserId,
          "fullName": usernameStr,
          "name": usernameStr,
          "avatar": avatarUrl,
        },
        "senderId": myUserId,
        "userAvatar": avatarUrl,
        "role": role,
        "isLiveStream": true,
      });
    } catch (e) {
      debugPrint("❌ Failed to broadcast comment via socket: $e");
    }

    // Broadcast message via Data Stream (Agora fallback)
    if (engine != null && _dataStreamId != null) {
      try {
        final payload = jsonEncode({
          "type": "comment",
          "username": usernameStr,
          "message": cleanMsg,
          "role": role,
          "avatar": avatarUrl,
        });
        final bytes = utf8.encode(payload);
        await engine!.sendStreamMessage(
          streamId: _dataStreamId!,
          data: Uint8List.fromList(bytes),
          length: bytes.length,
        );
        debugPrint("✅ Broadcasted comment via Agora: $payload");
      } catch (e) {
        debugPrint("❌ Failed to broadcast comment via Agora: $e");
      }
    }
  }

  void sendLike() {
    isLiked.toggle();
    if (isLiked.value) {
      likeCount.value++;
    } else {
      if (likeCount.value > 0) likeCount.value--;
    }

    // Broadcast via Socket.io
    try {
      final socketService = Get.find<SocketService>();
      final myUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
      socketService.emitEvent('new message', {
        "chat": streamId.value,
        "chatId": streamId.value,
        "content": isLiked.value ? "❤️ Liked the stream" : "💔 Unliked the stream",
        "text": isLiked.value ? "❤️ Liked the stream" : "💔 Unliked the stream",
        "message": isLiked.value ? "❤️ Liked the stream" : "💔 Unliked the stream",
        "sender": {
          "_id": myUserId,
          "fullName": "Viewer",
          "name": "Viewer",
        },
        "senderId": myUserId,
        "role": "viewer",
        "isLike": true,
        "isLiveStream": true,
      });
    } catch (_) {}

    if (engine != null && _dataStreamId != null) {
      try {
        final payload = jsonEncode({
          "type": "like",
        });
        final bytes = utf8.encode(payload);
        engine!.sendStreamMessage(
          streamId: _dataStreamId!,
          data: Uint8List.fromList(bytes),
          length: bytes.length,
        );
        debugPrint("✅ Broadcasted like");
      } catch (e) {
        debugPrint("❌ Failed to broadcast like: $e");
      }
    }
  }

  void _handleIncomingStreamMessage(Map<String, dynamic> payload) {
    final type = payload['type'];
    final avatar = payload['avatar']?.toString() ?? '';
    
    if (type == 'comment') {
      final username = payload['username'] ?? '';
      final msg = payload['message'] ?? '';
      final role = payload['role'] ?? 'viewer';
      
      // Skip if already added locally
      final senderName = username.toString().startsWith('@') ? username : '@$username';
      if (chatMessages.any((m) => m['user'] == senderName && m['msg'] == msg)) return;

      chatMessages.add({
        "user": senderName,
        "msg": msg,
        "role": role,
        "userAvatar": avatar,
      });
    } else if (type == 'bid') {
      final username = payload['username'] ?? '';
      final amount = double.tryParse(payload['amount']?.toString() ?? '0') ?? 0.0;
      final sid = payload['senderId']?.toString() ?? '';
      final isExtended = payload['extendTimer'] == true;
      
      lastBidderId.value = sid;
      lastBidderName.value = username.replaceAll('@', '');

      if (amount > currentBidPrice.value) {
        currentBidPrice.value = amount;
      }
      if (isExtended) {
        extendTimerLocal();
      }

      final msg = "🔨 Placed bid: \$${amount.toStringAsFixed(0)}";
      final senderName = username.toString().startsWith('@') ? username : '@$username';
      if (chatMessages.any((m) => m['user'] == senderName && m['msg'] == msg)) return;

      chatMessages.add({
        "user": senderName,
        "msg": msg,
        "isBid": "true",
        "userAvatar": avatar,
      });
    } else if (type == 'like') {
      likeCount.value++;
      triggerFloatingHeart(); // Trigger float heart animation!
    } else if (type == 'join') {
      final username = payload['username'] ?? 'Viewer';
      chatMessages.add({
        "user": username.toString(),
        "msg": "joined this stream",
        "role": "system",
        "userAvatar": avatar,
        "isJoin": "true",
      });
    } else if (type == 'extend_timer') {
      extendTimerLocal();
    } else if (type == 'new_auction') {
      auctionItemId.value = payload['auctionItemId']?.toString() ?? '';
      currentProductTitle.value = payload['productTitle']?.toString() ?? 'Product';
      currentProductImage.value = payload['productImage']?.toString() ?? '';
      currentBidPrice.value = double.tryParse(payload['startingBid']?.toString() ?? '0') ?? 0.0;
      lastBidderId.value = "";
      lastBidderName.value = "";
      showWinnerOverlay.value = false;
      auctionActive.value = true;
      
      final duration = int.tryParse(payload['timerDuration']?.toString() ?? '60') ?? 60;
      startCountdown(duration);

      chatMessages.add({
        "user": "System",
        "msg": "📢 Starting a new auction for ${currentProductTitle.value}!",
        "role": "system",
        "isJoin": "false",
        "userAvatar": "",
      });
    }
  }

  void toggleCamera() {
    if (engine != null) {
      isCameraOn.value = !isCameraOn.value;
      engine!.enableLocalVideo(isCameraOn.value);
    }
  }

  void toggleMic() {
    if (engine != null) {
      isMicOn.value = !isMicOn.value;
      engine!.enableLocalAudio(isMicOn.value);
    }
  }

  // ─────────────────────────────────────────────
  //  AGORA INIT
  // ─────────────────────────────────────────────
  Future<bool> _initAgora({required bool isHost, required String channel}) async {
    try {
      // 0) Fetch dynamic token from backend
      final response = await _apiClient.getData(
        "${ApiUrl.agoraToken}?channelName=$channel&uid=0&role=publisher"
      );
      
      String token = "";
      String dynamicAppId = agoraAppId; // Fallback to current appId if backend fails
      int userUid = 0;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'];
          token = data['token'] ?? "";
          dynamicAppId = data['appId'] ?? agoraAppId;
          userUid = data['uid'] ?? 0;
          debugPrint("✅ Token fetched from server: $token");
          debugPrint("✅ Dynamic App ID: $dynamicAppId");
        }
      } else {
        debugPrint("⚠️ Failed to fetch token from backend: ${response.statusCode}. Trying fallback with empty token.");
      }

      // 1) Request permissions (only if Host)
      if (isHost) {
        final camStatus = await Permission.camera.request();
        final micStatus = await Permission.microphone.request();
        debugPrint("📷 Camera: $camStatus | 🎤 Mic: $micStatus");
      }

      // 2) Create engine
      if (engine != null) {
        try {
          await engine!.leaveChannel();
          await engine!.release();
        } catch (_) {}
        engine = null;
      }
      engine = createAgoraRtcEngine();
      await engine!.initialize(RtcEngineContext(appId: dynamicAppId));
      debugPrint("✅ Agora Engine initialized");

      // 3) Event handlers
      engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) async {
          debugPrint("✅ Joined channel: ${connection.channelId}");
          isLocalVideoReady.value = true;
          try {
            _dataStreamId = await engine?.createDataStream(
              const DataStreamConfig(syncWithAudio: false, ordered: true),
            );
            debugPrint("✅ Agora Data Stream created with ID: $_dataStreamId");
          } catch (e) {
            debugPrint("❌ Failed to create Agora Data Stream: $e");
          }
        },
        onStreamMessage: (connection, remoteUid, streamId, data, length, sentTs) {
          try {
            final payloadStr = utf8.decode(data);
            final payload = jsonDecode(payloadStr);
            debugPrint("📩 Received Data Stream message: $payload");
            _handleIncomingStreamMessage(payload);
          } catch (e) {
            debugPrint("❌ Error decoding stream message: $e");
          }
        },
        onUserJoined: (connection, uid, elapsed) {
          debugPrint("👤 Remote user joined: $uid");
          remoteUid.value = uid;
          remoteJoined.value = true;
        },
        onUserOffline: (connection, uid, reason) {
          debugPrint("👤 Remote user left: $uid");
          if (uid == remoteUid.value) {
            remoteUid.value = -1;
            remoteJoined.value = false;
          }
        },
        onError: (err, msg) {
          debugPrint("❌ Agora Error: $err - $msg");
          if (err.toString().contains("InvalidToken") || err.toString().contains("110")) {
            Get.snackbar(
              "Agora Token Required",
              "Dynamic token authorization failed. Please contact support or check backend config.",
              backgroundColor: const Color(0xFFFF6B35),
              colorText: Colors.white,
              duration: const Duration(seconds: 10),
              snackPosition: SnackPosition.TOP,
            );
          }
        },
      ));

      // 4) Setup channel profile
      await engine!.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

      if (isHost) {
        await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await engine!.enableVideo();
        await engine!.startPreview();
        isLocalVideoReady.value = true; // Show camera immediately after preview starts
      } else {
        await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        await engine!.muteLocalVideoStream(true);
        await engine!.muteLocalAudioStream(true);
        await engine!.enableVideo();
      }

      // 5) Join channel
      await engine!.joinChannel(
        token: token,
        channelId: channel,
        uid: userUid,
        options: const ChannelMediaOptions(),
      );
      debugPrint("✅ Agora channel joined: $channel");
      return true;
    } catch (e) {
      debugPrint("❌ Agora init failed: $e");
      engine = null;
      // Show user-friendly error
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('No implementation found')) {
        Get.snackbar(
          "Agora Setup Required",
          "Camera plugin not ready. Please do a full app reinstall (flutter clean → flutter run).",
          backgroundColor: const Color(0xFFFF6B35),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          "Stream Error",
          "Could not start camera: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}",
          backgroundColor: Colors.red.withValues(alpha: 0.85),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
      return false;
    }
  }

  Future<bool> resetAndStartNewAuction({
    required String productId,
    required double startingBid,
    required int timerDuration,
    String productTitle = "",
    String productImage = "",
  }) async {
    isLoading.value = true;
    try {
      if (productId.isNotEmpty && streamId.value.isNotEmpty) {
        final itemRes = await _apiClient.postData(ApiUrl.addAuctionItem, {
          "streamId": streamId.value,
          "productId": productId,
          "startingBid": startingBid,
          "bidIncrement": 100,
          "timerDuration": timerDuration,
        });
        if (itemRes.statusCode == 200 || itemRes.statusCode == 201) {
          final itemBody = jsonDecode(itemRes.body);
          auctionItemId.value = itemBody['data']?['_id'] ?? itemBody['_id'] ?? itemBody['data']?['id'] ?? itemBody['id'] ?? "";
          currentProductTitle.value = productTitle;
          currentProductImage.value = productImage;
          currentBidPrice.value = startingBid;
          lastBidderId.value = "";
          lastBidderName.value = "";
          showWinnerOverlay.value = false;
          auctionActive.value = true;

          // Broadcast new auction via socket
          try {
            final socketService = Get.find<SocketService>();
            socketService.emitEvent('new message', {
              "chat": streamId.value,
              "chatId": streamId.value,
              "content": "📢 Starting a new auction for $productTitle!",
              "sender": {
                "_id": SharePrefsHelper.getString(SharePrefsHelper.userIdKey),
                "fullName": "System",
              },
              "isNewAuction": true,
              "productId": productId,
              "productTitle": productTitle,
              "productImage": productImage,
              "startingBid": startingBid,
              "timerDuration": timerDuration,
              "auctionItemId": auctionItemId.value,
              "isLiveStream": true,
            });
          } catch (_) {}

          // Broadcast new auction via Agora
          if (engine != null && _dataStreamId != null) {
            try {
              final payload = jsonEncode({
                "type": "new_auction",
                "auctionItemId": auctionItemId.value,
                "productId": productId,
                "productTitle": productTitle,
                "productImage": productImage,
                "startingBid": startingBid,
                "timerDuration": timerDuration,
              });
              final bytes = utf8.encode(payload);
              await engine!.sendStreamMessage(
                streamId: _dataStreamId!,
                data: Uint8List.fromList(bytes),
                length: bytes.length,
              );
            } catch (_) {}
          }

          startCountdown(timerDuration);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("❌ Failed to start new auction: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  //  END STREAM
  // ─────────────────────────────────────────────
  Future<void> endStream() async {
    _countdownTimer?.cancel();
    _cleanupSocket();
    await engine?.leaveChannel();
    await engine?.stopPreview();
    await engine?.release();
    engine = null;
    isLive.value = false;
    isLocalVideoReady.value = false;
    remoteJoined.value = false;
    remoteUid.value = -1;
    auctionActive.value = false;
    
    // Manually delete the permanent GetX controller instance
    Get.delete<AgoraLiveController>(force: true);
    Get.offAllNamed('/main');
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _cleanupSocket();
    engine?.leaveChannel();
    engine?.release();
    super.onClose();
  }
}
