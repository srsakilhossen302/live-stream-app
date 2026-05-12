import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/main_controller.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainController());
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: Obx(() => controller.screens[controller.currentIndex.value]),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      height: 100.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.r),
          topRight: Radius.circular(40.r),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(0, "assets/icons/Purchases-navBar.svg", "Purchases"),
          _navItem(1, "assets/icons/Discover-navBar.svg", "Discover"),
          _navItem(2, "assets/icons/Bidswap-navBar.svg", "Bidswap"),
          _navItem(3, "assets/icons/Home-navBar.svg", "Home"),
          _navItem(4, "assets/icons/Profile-navBar.svg", "Profile"),
        ],
      ),
    );
  }

  Widget _navItem(int index, String iconPath, String label) {
    return Obx(() {
      bool isSelected = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 16.w : 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B9BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24.w,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  isSelected ? const Color(0xFF0F0B1E) : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF0F0B1E),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
