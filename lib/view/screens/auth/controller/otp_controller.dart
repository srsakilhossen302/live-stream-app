import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/app_route.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

class OtpController extends GetxController {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  final RxInt timerSeconds = 60.obs;
  bool _isTimerRunning = false;
  
  String email = "";
  final RxBool isLoading = false.obs;
  final ApiClient _apiClient = Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments ?? "";
    startTimer();
  }

  void startTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    timerSeconds.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
        return true;
      }
      _isTimerRunning = false;
      return false;
    });
  }

  Future<void> onVerify() async {
    String otp = pinController.text;
    if (otp.length != 6) {
      Get.snackbar("Error", "Please enter 6-digit OTP", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    if (email.isEmpty) {
      Get.snackbar("Error", "Email address is missing. Please try signing up again.", backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final response = await _apiClient.postData(
        ApiUrl.verifyAccount,
        {
          "email": email,
          "oneTimeCode": otp,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          final dataMap = responseData['data'];
          final accessToken = dataMap['accessToken'] ?? '';
          final refreshToken = dataMap['refreshToken'] ?? '';

          if (accessToken.isNotEmpty) {
            await SharePrefsHelper.setString(SharePrefsHelper.accessTokenKey, accessToken);
          }
          if (refreshToken.isNotEmpty) {
            await SharePrefsHelper.setString(SharePrefsHelper.refreshTokenKey, refreshToken);
          }
          await SharePrefsHelper.setBool(SharePrefsHelper.isLoginKey, true);
        }

        Get.snackbar(
          "Success",
          "Verification Successful!",
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoute.category);
      } else {
        String errorMessage = "Verification failed. Please check the code.";
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

  void onResend() {
    if (timerSeconds.value == 0) {
      Get.log("OTP Resent");
      startTimer();
    }
  }

  @override
  void onClose() {
    pinController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
