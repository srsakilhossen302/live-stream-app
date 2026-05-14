import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Change password",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),
              
              Text(
                "Security & Password",
                style: TextStyle(
                  color: const Color(0xFF8B9BFF),
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Manage your account security and\nauthentication settings.",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14.sp,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: 48.h),
              
              Row(
                children: [
                  Icon(Icons.history_rounded, color: Colors.white38, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    "CHANGE PASSWORD",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(28.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF11111E),
                  borderRadius: BorderRadius.circular(32.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPasswordField("CURRENT PASSWORD"),
                    SizedBox(height: 32.h),
                    _buildPasswordField("NEW PASSWORD"),
                    SizedBox(height: 32.h),
                    _buildPasswordField("CONFIRM NEW PASSWORD"),
                    
                    SizedBox(height: 48.h),
                    
                    Container(
                      width: double.infinity,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B9BFF),
                        borderRadius: BorderRadius.circular(32.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B9BFF).withOpacity(0.3),
                            blurRadius: 20.r,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Update Password",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white24,
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "••••••••••••",
          style: TextStyle(
            color: Colors.white.withOpacity(0.1),
            fontSize: 24.sp,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8.h),
        Divider(color: Colors.white.withOpacity(0.05), thickness: 1.5),
      ],
    );
  }
}
