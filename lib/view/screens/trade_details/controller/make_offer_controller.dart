import 'dart:convert';
import 'package:get/get.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

class MakeOfferController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxMap<String, dynamic> sellerProduct = <String, dynamic>{}.obs;
  final RxList<dynamic> userProducts = <dynamic>[].obs;
  final Rxn<Map<String, dynamic>> selectedUserProduct = Rxn<Map<String, dynamic>>();
  final RxDouble cashSupplement = 0.0.obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      sellerProduct.assignAll(Map<String, dynamic>.from(Get.arguments));
    }
    fetchUserProducts();
  }

  Future<void> fetchUserProducts() async {
    final userId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await _apiClient.getData("${ApiUrl.products}?sellerId=$userId");
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final list = body['data'] ?? body['products'] ?? body['result'] ?? [];
        if (list is List) {
          userProducts.assignAll(list);
          if (list.isNotEmpty) {
            selectedUserProduct.value = Map<String, dynamic>.from(list[0]);
          }
        }
      }
    } catch (e) {
      Get.log("Error fetching user products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectProduct(Map<String, dynamic> product) {
    selectedUserProduct.value = product;
  }

  void updateCashSupplement(double val) {
    cashSupplement.value = val;
  }

  double get sellerProductValue {
    final val = sellerProduct['estValue'] ?? sellerProduct['buyNowPrice'] ?? '0';
    return double.tryParse(val.toString()) ?? 0.0;
  }

  double get userProductValue {
    if (selectedUserProduct.value == null) return 0.0;
    final val = selectedUserProduct.value!['estValue'] ?? selectedUserProduct.value!['buyNowPrice'] ?? '0';
    return double.tryParse(val.toString()) ?? 0.0;
  }

  double get valueDelta {
    // Delta = (User Product Value + Cash Supplement) - Seller Product Value
    return (userProductValue + cashSupplement.value) - sellerProductValue;
  }

  Future<void> sendOffer() async {
    if (selectedUserProduct.value == null) {
      Get.snackbar("Error", "Please select a product from your inventory to offer.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final senderId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
    final seller = sellerProduct['sellerId'];
    final receiverId = (seller is Map) ? (seller['_id'] ?? seller['id'] ?? "") : seller.toString();
    
    final senderProductId = selectedUserProduct.value!['_id'] ?? selectedUserProduct.value!['id'] ?? "";
    final receiverProductId = sellerProduct['_id'] ?? sellerProduct['id'] ?? "";

    if (senderId.isEmpty || receiverId.isEmpty || senderProductId.isEmpty || receiverProductId.isEmpty) {
      Get.snackbar("Error", "Missing sender/receiver/product information.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      final payload = {
        "senderId": senderId,
        "receiverId": receiverId,
        "senderProductId": senderProductId,
        "receiverProductId": receiverProductId,
        "cashSupplement": cashSupplement.value,
      };

      final response = await _apiClient.postData("/trades/offer", payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true || response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar("Success", "Trade offer sent successfully!", snackPosition: SnackPosition.BOTTOM);
          Get.back();
        } else {
          Get.snackbar("Error", body['message'] ?? "Failed to send trade offer", snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        Get.snackbar("Error", "Failed to send trade offer. Status: ${response.statusCode}", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }
}
