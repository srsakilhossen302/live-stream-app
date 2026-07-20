import 'dart:convert';
import 'package:get/get.dart';
import '../../../../../../data/services/api_client.dart';
import '../../../model/purchase_model.dart';

class TrackOrderController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> orderData = <String, dynamic>{}.obs;

  String orderId = '';
  PurchaseModel? fallbackModel;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      orderId = args;
    } else if (args is PurchaseModel) {
      fallbackModel = args;
      orderId = args.id;
    } else if (args is Map) {
      orderId = (args['_id'] ?? args['id'] ?? args['orderId'] ?? '').toString();
    }

    if (orderId.isNotEmpty) {
      fetchOrderDetails();
    }
  }

  Future<void> fetchOrderDetails() async {
    if (orderId.isEmpty) return;
    isLoading.value = true;
    try {
      final response = await _apiClient.getData("/orders/$orderId");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is Map) {
          orderData.assignAll(Map<String, dynamic>.from(body['data']));
        }
      }
    } catch (e) {
      Get.log("Error fetching order details ($orderId): $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 1. Delivery status and estimated delivery
  String get deliveryStatus {
    if (orderData.containsKey('deliveryStatus')) {
      return orderData['deliveryStatus']?.toString() ?? 'In Transit';
    }
    if (fallbackModel != null) {
      return fallbackModel!.status == OrderStatus.delivered ? 'Delivered' : 'In Transit';
    }
    return 'In Transit';
  }

  String get estimatedDelivery {
    final est = orderData['trackingDetails']?['estimatedDelivery']?.toString();
    if (est != null && est.isNotEmpty) return est;
    return fallbackModel?.estimatedDelivery ?? 'Apr 23, 2026';
  }

  // 2. Journey Updates (Array)
  List<dynamic> get journeyUpdates {
    final list = orderData['trackingDetails']?['journeyUpdates'];
    if (list is List && list.isNotEmpty) return list;
    return [
      {
        "status": "In Transit: Arrived at Facility",
        "description": "Package arrived at Jersey City, NJ distribution center",
        "timestamp": "Today 10:25 AM"
      },
      {
        "status": "Shipped",
        "description": "Package left origin facility",
        "timestamp": "Apr 21"
      },
      {
        "status": "Order Confirmed",
        "description": "Seller accepted your order",
        "timestamp": "Apr 21"
      }
    ];
  }

  // 3. Product info
  String get productTitle {
    final prod = orderData['productId'] ?? orderData['product'];
    if (prod is Map) return prod['title']?.toString() ?? prod['name']?.toString() ?? 'Product';
    if (orderData['productName'] != null) return orderData['productName'].toString();
    return fallbackModel?.title ?? 'Product';
  }

  String get productImage {
    final prod = orderData['productId'] ?? orderData['product'];
    if (prod is Map && prod['images'] is List && (prod['images'] as List).isNotEmpty) {
      return prod['images'][0].toString();
    }
    return fallbackModel?.image ?? '';
  }

  String get displayOrderId => orderData['_id']?.toString() ?? fallbackModel?.id ?? orderId;

  // 4. Payment breakdown (amountDetails)
  Map<String, dynamic> get amountDetails {
    final details = orderData['amountDetails'];
    if (details is Map) return Map<String, dynamic>.from(details);
    return {};
  }

  double get itemSubtotal {
    final val = amountDetails['itemSubtotal'];
    if (val != null) return double.tryParse(val.toString()) ?? 115.0;
    return fallbackModel?.itemPrice ?? 115.0;
  }

  double get shipping {
    final val = amountDetails['shipping'];
    if (val != null) return double.tryParse(val.toString()) ?? 15.0;
    return fallbackModel?.shippingPrice ?? 15.0;
  }

  double get taxes {
    final val = amountDetails['taxes'];
    if (val != null) return double.tryParse(val.toString()) ?? 0.0;
    return fallbackModel?.taxes ?? 0.0;
  }

  double get processingFee {
    final val = amountDetails['processingFee'];
    if (val != null) return double.tryParse(val.toString()) ?? 0.0;
    return fallbackModel?.processingFee ?? 0.0;
  }

  double get charityContribution {
    final val = amountDetails['charityContribution'];
    if (val != null) return double.tryParse(val.toString()) ?? 0.05;
    return fallbackModel?.buyerContribution ?? 0.05;
  }

  double get totalPaid {
    final val = amountDetails['totalPaid'];
    if (val != null) return double.tryParse(val.toString()) ?? 130.05;
    return fallbackModel?.totalPaid ?? 130.05;
  }
}
