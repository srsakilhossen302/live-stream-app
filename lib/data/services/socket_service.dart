import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../helpers/shared_prefe.dart';
import 'api_url.dart';

class SocketService extends GetxService {
  static SocketService get to => Get.find();
  
  IO.Socket? socket;
  final RxBool isConnected = false.obs;

  void initSocket() {
    final token = SharePrefsHelper.getString(SharePrefsHelper.accessTokenKey);
    final userId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
    
    if (token.isEmpty || userId.isEmpty) {
      Get.log("⚡ [SocketService] Connection skipped: Token or UserId is empty.");
      return;
    }

    if (socket != null && socket!.connected) {
      Get.log("⚡ [SocketService] Already connected.");
      return;
    }

    try {
      final socketUrl = ApiUrl.imageBaseUrl;
      Get.log("⚡ [SocketService] Connecting to: $socketUrl");

      socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .setQuery({
              'token': token,
              'userId': userId,
            })
            .build(),
      );

      socket?.onConnect((_) {
        isConnected.value = true;
        Get.log("⚡ [SocketService] Socket Connected: ${socket?.id}");
        socket?.emit('setup', userId);
      });

      socket?.onDisconnect((_) {
        isConnected.value = false;
        Get.log("🔌 [SocketService] Socket Disconnected");
      });

      socket?.onConnectError((data) {
        Get.log("❌ [SocketService] Connect Error: $data");
      });

      socket?.onError((data) {
        Get.log("❌ [SocketService] Error: $data");
      });

    } catch (e) {
      Get.log("❌ [SocketService] Initialization Exception: $e");
    }
  }

  void joinChat(String chatId) {
    if (socket == null || !isConnected.value) {
      Get.log("⚠️ [SocketService] Cannot join room: socket not connected.");
      return;
    }
    Get.log("🎯 [SocketService] Joining chat room: $chatId");
    socket?.emit('join chat', chatId);
  }

  void leaveChat(String chatId) {
    if (socket == null || !isConnected.value) return;
    Get.log("🚪 [SocketService] Leaving chat room: $chatId");
    socket?.emit('leave chat', chatId);
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
    isConnected.value = false;
    Get.log("🔌 [SocketService] Socket disconnected manually.");
  }

  @override
  void onClose() {
    disconnectSocket();
    super.onClose();
  }
}
