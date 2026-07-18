import 'package:get/get.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
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
      final productId = product['_id'] ?? product['id'] ?? "";
      final double subtotal = double.tryParse(product['buyNowPrice']?.toString() ?? product['estValue']?.toString() ?? '250') ?? 250.0;
      final String productTitle = product['title'] ?? 'Product Purchase';

      final payload = {
        "amount": subtotal,
        "currency": "USD",
        "productName": productTitle,
        "metadata": {
          "purchaseType": "buy_now",
          "productId": productId
        }
      };

      final response = await _apiClient.postData("/payments/create-checkout-session", payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = jsonDecode(response.body);
        final success = resBody['success'] ?? false;
        final data = resBody['data'];
        
        if (success && data is Map && data.containsKey('checkoutUrl')) {
          final checkoutUrl = data['checkoutUrl'].toString();
          final uri = Uri.parse(checkoutUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            Get.snackbar("Success", "Redirecting to Stripe checkout...", snackPosition: SnackPosition.BOTTOM);
          } else {
            Get.snackbar("Error", "Could not launch checkout screen.", snackPosition: SnackPosition.BOTTOM);
          }
        } else {
          Get.snackbar("Error", resBody['message'] ?? "Failed to initiate payment session", snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar("Error", "Failed to initiate payment. Status code: ${response.statusCode}", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isOrdering.value = false;
    }
  }
}
