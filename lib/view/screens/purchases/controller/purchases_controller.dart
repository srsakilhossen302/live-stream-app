import 'dart:convert';
import 'package:get/get.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../model/purchase_model.dart';

class PurchasesController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final RxBool isLoading = false.obs;
  
  var selectedTab = 0.obs;
  final tabs = ["All", "In Transit", "Delivered", "Cancelled"];
  final purchases = <PurchaseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    final userId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
    if (userId.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await _apiClient.getData("${ApiUrl.userOrders}?userId=$userId&role=buyer");
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        final parsed = data.map((item) {
          final title = item['productId'] != null ? (item['productId']['title'] ?? "Item") : "Item";
          
          final imagesList = item['productId'] != null ? item['productId']['images'] : null;
          String imageUrl = "";
          if (imagesList != null && imagesList is List && imagesList.isNotEmpty) {
            final imagePath = imagesList[0].toString();
            imageUrl = imagePath.startsWith('http')
                ? imagePath
                : "${ApiUrl.imageBaseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}";
          }

          final rawStatus = item['status']?.toString().toLowerCase() ?? "";
          OrderStatus status = OrderStatus.processing;
          int trackingStep = 2;
          if (rawStatus.contains('transit')) {
            status = OrderStatus.inTransit;
            trackingStep = 3;
          } else if (rawStatus.contains('deliver')) {
            status = OrderStatus.delivered;
            trackingStep = 5;
          } else if (rawStatus.contains('cancel')) {
            status = OrderStatus.cancelled;
            trackingStep = 1;
          }

          final amountDetails = item['amountDetails'] ?? {};
          final total = (amountDetails['totalPaid'] ?? 0.0).toDouble();

          return PurchaseModel(
            id: "#ORD-${item['_id']?.toString().substring((item['_id']?.toString().length ?? 5) - 5).toUpperCase() ?? ''}",
            title: title,
            curator: item['productId'] != null && item['productId']['sellerId'] != null 
                ? "@${item['productId']['sellerId']['username'] ?? 'seller'}"
                : "@seller",
            date: item['createdAt'] != null ? "Purchased ${_formatDate(item['createdAt'].toString())}" : "Purchased recently",
            price: "\$${total.toStringAsFixed(2)}",
            carrier: item['carrier'] ?? "USPS Ground",
            image: imageUrl,
            trackingId: item['trackingId'] ?? "TRK-${item['_id']?.toString().substring(0, 8).toUpperCase() ?? ''}",
            status: status,
            trackingStep: trackingStep,
            estimatedDelivery: item['estimatedDelivery'] ?? "TBD",
            location: item['location'] ?? "Facility",
            itemPrice: (amountDetails['itemSubtotal'] ?? 0.0).toDouble(),
            shippingPrice: (amountDetails['shipping'] ?? 0.0).toDouble(),
            taxes: (amountDetails['taxes'] ?? 0.0).toDouble(),
            processingFee: (amountDetails['processingFee'] ?? 0.0).toDouble(),
            buyerContribution: (amountDetails['charityContribution'] ?? 0.0).toDouble(),
            totalPaid: total,
          );
        }).toList();
        purchases.assignAll(parsed);
      }
    } catch (e) {
      Get.log("Error fetching purchases: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (_) {
      return "recently";
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  List<PurchaseModel> get filteredPurchases {
    if (selectedTab.value == 0) return purchases;
    
    OrderStatus targetStatus;
    switch (selectedTab.value) {
      case 1:
        targetStatus = OrderStatus.inTransit;
        break;
      case 2:
        targetStatus = OrderStatus.delivered;
        break;
      case 3:
        targetStatus = OrderStatus.cancelled;
        break;
      default:
        return purchases;
    }
    
    return purchases.where((p) => p.status == targetStatus).toList();
  }
}
