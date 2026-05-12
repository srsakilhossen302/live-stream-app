import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    return CustomBackground(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C).withOpacity(0.9),
                borderRadius: BorderRadius.circular(32.r),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Step back into the world's most exclusive auctions.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 48.h),
                  
                  // Email Field
                  _buildLabel("EMAIL OR USERNAME"),
                  TextField(
                    controller: controller.emailController,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    decoration: InputDecoration(
                      hintText: "Enter your credentials",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 16.sp),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8B9BFF))),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Password Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel("PASSWORD"),
                      GestureDetector(
                        onTap: () => controller.onForgotPassword(),
                        child: Text(
                          "FORGOT PASSWORD?",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    decoration: InputDecoration(
                      hintText: "••••••••",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 16.sp),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8B9BFF))),
                    ),
                  ),
                  
                  SizedBox(height: 48.h),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () => controller.onLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B9BFF),
                        foregroundColor: const Color(0xFF0F0B1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                      ),
                      GestureDetector(
                        onTap: () => controller.onSignUp(),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: const Color(0xFF8B9BFF),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF8B9BFF),
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
