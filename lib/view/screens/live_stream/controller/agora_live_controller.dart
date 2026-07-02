import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

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

  // Live streams list (for Discover)
  final RxList<Map<String, dynamic>> liveStreamsList = <Map<String, dynamic>>[].obs;
  final RxBool loadingStreams = false.obs;

  // Messages / chat
  final RxList<Map<String, String>> chatMessages = <Map<String, String>>[].obs;

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
          auctionActive.value = true;
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
      final channel = streamData['agoraChannelName']?.toString() ?? "";
      final sid = streamData['_id']?.toString() ?? "";
      streamId.value = sid;
      channelName.value = channel;
      streamTitle.value = streamData['title']?.toString() ?? "Live Stream";

      // Parse product info if available
      final items = streamData['auctionItems'];
      if (items is List && items.isNotEmpty) {
        final item = items[0];
        currentProductTitle.value = item['productId']?['title']?.toString() ?? "Product";
        currentProductImage.value = item['productId']?['images']?[0]?.toString() ?? "";
        currentBidPrice.value = double.tryParse(item['currentBid']?.toString() ?? "0") ?? 0;
        auctionItemId.value = item['_id']?.toString() ?? "";
        auctionActive.value = true;
      }

      final agoraOk = await _initAgora(isHost: false, channel: channel);
      debugPrint(agoraOk ? "✅ Agora viewer ready" : "⚠️ Agora failed — viewing in backend-only mode");
      isLive.value = true;
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
    if (auctionItemId.value.isEmpty) return;
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
        chatMessages.add({"user": "You", "msg": "🔨 Placed bid: \$${amount.toStringAsFixed(0)}"});
        Get.back(); // close bid sheet
        Get.snackbar("Bid Placed!", "Your bid of \$${amount.toStringAsFixed(0)} is live!", snackPosition: SnackPosition.BOTTOM);
      } else {
        final body = jsonDecode(res.body);
        Get.snackbar("Error", body['message'] ?? "Bid failed", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Bid error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void sendChatMessage(String msg) {
    if (msg.trim().isEmpty) return;
    chatMessages.add({"user": "You", "msg": msg.trim()});
    // Note: clearing the TextField controller is done by the widget
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
      final roleStr = isHost ? "publisher" : "subscriber";
      final response = await _apiClient.getData(
        "${ApiUrl.agoraToken}?channelName=$channel&uid=0&role=$roleStr"
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
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("✅ Joined channel: ${connection.channelId}");
          isLocalVideoReady.value = true;
        },
        onUserJoined: (connection, uid, elapsed) {
          debugPrint("👤 Remote user joined: $uid");
          remoteUid.value = uid;
          remoteJoined.value = true;
          chatMessages.add({"user": "System", "msg": "A viewer joined the stream!"});
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
        await engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
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

  // ─────────────────────────────────────────────
  //  END STREAM
  // ─────────────────────────────────────────────
  Future<void> endStream() async {
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
    engine?.leaveChannel();
    engine?.release();
    // TextEditingControllers are disposed by their widgets' dispose() method
    super.onClose();
  }
}
