import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/app_route.dart';

class OtpController extends GetxController {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  final RxInt timerSeconds = 60.obs;
  bool _isTimerRunning = false;

  @override
  void onInit() {
    super.onInit();
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

  void onVerify() {
    String otp = pinController.text;
    if (otp.length == 6) {
      Get.log("OTP Verified: $otp");
      Get.offAllNamed(AppRoute.category);
    } else {
      Get.snackbar("Error", "Please enter 6-digit OTP");
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
