import 'package:get/get.dart';
import '../data/services/api_client.dart';

class DependencyInjection {
  static void init() {
    Get.lazyPut(() => ApiClient(), fenix: true);
  }
}
