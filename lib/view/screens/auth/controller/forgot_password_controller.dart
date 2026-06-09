import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/app_route.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final RxBool isLoading = false.obs;
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<void> onForgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        "Required",
        "Email address is required",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _apiClient.postData(
        ApiUrl.forgotPassword,
        {
          "email": email,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Password reset request sent successfully!",
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        emailController.clear();
        await Future.delayed(const Duration(seconds: 1));
        Get.toNamed(AppRoute.otp, arguments: {
          'email': email,
          'fromForgotPassword': true,
        });
      } else {
        String errorMessage = "Failed to send reset request. Please check the email.";
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) {
            errorMessage = data['message'];
          } else if (data['error'] != null) {
            errorMessage = data['error'];
          }
        } catch (_) {}

        Get.snackbar(
          "Error",
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred. Please check your connection.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
