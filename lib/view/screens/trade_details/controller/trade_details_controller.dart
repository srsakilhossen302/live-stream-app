import 'package:get/get.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

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
        Future.microtask(() {
          product.assignAll(Map<String, dynamic>.from(Get.arguments));
          _checkAndFetchSellerDetails();
        });
      }
    }
  }

  Future<void> _checkAndFetchSellerDetails() async {
    try {
      final seller = product['sellerId'];
      String sellerId = '';
      bool needFetch = false;

      if (seller is String && seller.isNotEmpty) {
        sellerId = seller;
        needFetch = true;
      } else if (seller is Map) {
        sellerId = (seller['_id'] ?? seller['id'] ?? '').toString();
        final name = seller['fullName'] ?? seller['name'] ?? 'Seller';
        if (name == 'Seller' || name == 'Curator' || name.toString().isEmpty) {
          needFetch = true;
        }
      }

      if (needFetch && sellerId.isNotEmpty) {
        final response = await _apiClient.getData("/users/$sellerId");
        if (response.statusCode == 200) {
          final resBody = jsonDecode(response.body);
          final userData = resBody['data'] ?? resBody;
          if (userData is Map) {
            final updatedProduct = Map<String, dynamic>.from(product);
            updatedProduct['sellerId'] = userData;
            product.assignAll(updatedProduct);
            Get.log("✅ [TradeDetailsController] Successfully loaded seller details for: $sellerId");
          }
        }
      }
    } catch (e) {
      Get.log("❌ [TradeDetailsController] Error fetching seller details: $e");
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

      final response = await _apiClient.postData(ApiUrl.createCheckoutSession, payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = jsonDecode(response.body);
        final success = resBody['success'] ?? false;
        final data = resBody['data'];

        // 1. Native Stripe PaymentSheet Handler
        if (success && data is Map && data.containsKey('clientSecret')) {
          await _initAndPresentPaymentSheet(data);
          return;
        }
        
        // 2. Checkout URL Handler
        String? checkoutUrl;
        if (data is Map) {
          checkoutUrl = (data['url'] ?? data['checkoutUrl'] ?? data['paymentUrl'] ?? data['redirectUrl'] ?? data['sessionUrl'])?.toString();
        } else if (data is String && data.startsWith('http')) {
          checkoutUrl = data;
        } else if (resBody['url'] != null) {
          checkoutUrl = resBody['url'].toString();
        }

        if (success && checkoutUrl != null && checkoutUrl.isNotEmpty) {
          final uri = Uri.parse(checkoutUrl);
          bool launched = false;
          try {
            launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          } catch (_) {}
          if (!launched) {
            try {
              launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
            } catch (_) {}
          }
          if (!launched) {
            try {
              launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {}
          }

          if (launched) {
            Get.snackbar("Success", "Redirecting to Stripe checkout...", snackPosition: SnackPosition.BOTTOM);
          } else {
            Get.snackbar("Error", "Could not open Stripe checkout page.", snackPosition: SnackPosition.BOTTOM);
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

  Future<bool> _initAndPresentPaymentSheet(Map<dynamic, dynamic> data) async {
    try {
      final clientSecret = data['clientSecret']?.toString() ?? '';
      final ephemeralKey = data['ephemeralKey']?.toString() ?? '';
      final customerId = data['customer']?.toString() ?? '';

      final pubKey = data['publishableKey'] ?? data['stripePublishableKey'] ?? data['pk'];
      if (pubKey != null && pubKey.toString().isNotEmpty) {
        Stripe.publishableKey = pubKey.toString();
        await Stripe.instance.applySettings();
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: ephemeralKey.isNotEmpty ? ephemeralKey : null,
          customerId: customerId.isNotEmpty ? customerId : null,
          merchantDisplayName: 'Culture Cards LLC',
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF8B9BFF),
              background: Color(0xFF161622),
              componentBackground: Color(0xFF1E1E2C),
              componentText: Colors.white,
              primaryText: Colors.white,
              secondaryText: Colors.white70,
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      Get.snackbar("Success", "Payment Completed! ✅", snackPosition: SnackPosition.BOTTOM);
      return true;
    } on StripeException catch (e) {
      Get.log("⚠️ Stripe Exception: ${e.error.localizedMessage}");
      Get.snackbar("Stripe Error", e.error.localizedMessage ?? "Payment was cancelled.", snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.log("❌ Stripe Error: $e");
      Get.snackbar("Error", "$e", snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
