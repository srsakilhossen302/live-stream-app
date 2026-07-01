import 'package:get/get.dart';

class TradeDetailsController extends GetxController {
  var currentImageIndex = 0.obs;
  final RxMap<String, dynamic> product = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        product.assignAll(Map<String, dynamic>.from(Get.arguments));
      }
    }
  }

  int get totalImages => (product['images'] as List?)?.length ?? 1;
}
