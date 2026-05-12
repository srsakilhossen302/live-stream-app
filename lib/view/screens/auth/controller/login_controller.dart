import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void onLogin() {
    Get.log("Login Clicked: ${emailController.text}");
  }

  void onSignUp() {
    Get.log("Sign Up Clicked");
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
