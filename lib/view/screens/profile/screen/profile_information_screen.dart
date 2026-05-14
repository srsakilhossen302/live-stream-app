import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';

class ProfileInformationScreen extends StatelessWidget {
  const ProfileInformationScreen({super.key});

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
            "Profile information",
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
              SizedBox(height: 32.h),
              
              // Profile Photo
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120.r,
                          height: 120.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF8B9BFF), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 56.r,
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.person, color: Colors.white24, size: 60.sp),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B9BFF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, color: Colors.black, size: 16.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "CHANGE PHOTO",
                      style: TextStyle(
                        color: const Color(0xFF8B9BFF),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 48.h),
              
              _buildInputField("FULL NAME", "Julian Sterling"),
              SizedBox(height: 24.h),
              _buildInputField("USERNAME", "@jsterling_collector", isPurple: true),
              SizedBox(height: 24.h),
              _buildInputField("EMAIL ADDRESS", "julian.sterling@kinetic.gallery"),
              SizedBox(height: 24.h),
              _buildInputField("PHONE NUMBER", "+1 (555) 892-0431"),
              SizedBox(height: 24.h),
              _buildInputField("BIO", "Passionate collector of digital kinetic art and rare physical masterpieces. Based in London. Always looking for the next piece that defies gravity.", maxLines: 4),
              
              SizedBox(height: 48.h),
              
              // Buttons
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
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 64.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(32.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Discard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String value, {bool isPurple = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF11111E),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isPurple ? const Color(0xFF8B9BFF) : Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }
}
