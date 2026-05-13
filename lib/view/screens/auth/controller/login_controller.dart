import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app_route.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void onLogin() {
    Get.offAllNamed(AppRoute.main);
  }

  void onSignUp() {
    Get.toNamed(AppRoute.signUp);
  }

  void onForgotPassword() {
    Get.log("Forgot Password Clicked");
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
