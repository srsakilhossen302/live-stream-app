import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_route.dart';

class SignUpController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool agreeToTerms = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  void onSignUp() {
    if (agreeToTerms.value) {
      Get.log("Sign Up Successful, navigating to OTP");
      Get.toNamed(AppRoute.otp);
    } else {
      Get.snackbar("Error", "Please agree to the Terms of Service");
    }
  }

  void onLogin() {
    Get.back();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
