import 'package:get/get.dart';
import 'dart:convert';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';

class TradeDetailsController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  var currentImageIndex = 0.obs;
  final RxMap<String, dynamic> product = <String, dynamic>{}.obs;
  final RxBool isOrdering = false.obs;

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

  Future<void> buyProduct() async {
    isOrdering.value = true;
    try {
      final buyerId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
      
      final seller = product['sellerId'];
      final sellerId = (seller is Map) ? (seller['_id'] ?? seller['id'] ?? "") : seller.toString();
      final productId = product['_id'] ?? product['id'] ?? "";
      
      final double subtotal = double.tryParse(product['buyNowPrice']?.toString() ?? product['estValue']?.toString() ?? '250') ?? 250.0;
      
      final payload = {
        "buyerId": buyerId,
        "sellerId": sellerId,
        "productId": productId,
        "purchaseType": "buy_now",
        "amountDetails": {
          "itemSubtotal": subtotal,
          "shipping": 15.0,
          "taxes": 12.0,
          "processingFee": 8.0,
          "charityContribution": 0.0,
          "totalPaid": subtotal + 35.0
        },
        "shippingAddress": {
          "street": "123 Collectors Lane",
          "city": "Metropolis",
          "state": "NY",
          "postalCode": "10001",
          "country": "US"
        }
      };

      final response = await _apiClient.postData("/orders", payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = jsonDecode(response.body);
        if (resBody['success'] == true) {
          Get.snackbar("Success", "Order placed successfully!", snackPosition: SnackPosition.BOTTOM);
          Get.offNamed('/purchases');
        } else {
          Get.snackbar("Error", resBody['message'] ?? "Failed to place order", snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar("Error", "Order placement failed. Status code: ${response.statusCode}", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isOrdering.value = false;
    }
  }
}
