import 'package:get/get.dart';
import '../data/services/api_client.dart';
import '../data/services/socket_service.dart';

class DependencyInjection {
  static void init() {
    Get.lazyPut(() => ApiClient(), fenix: true);
    Get.lazyPut(() => SocketService(), fenix: true);
  }
}
