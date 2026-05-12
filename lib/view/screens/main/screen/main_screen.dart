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
      body: Stack(
        children: [
          Obx(() => controller.screens[controller.currentIndex.value]),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPart(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPart() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // Navbar Background
        Container(
          height: 95.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0B1E), // Matching exact dark purple from mockup
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.r),
              topRight: Radius.circular(40.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30.r,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(0, "assets/icons/Home-navBar.svg", "Home"),
              _navItem(1, "assets/icons/Purchases-navBar.svg", "Purchases"),
              SizedBox(width: 50.w), // Gap for FAB
              _navItem(2, "assets/icons/Discover-navBar.svg", "Discover"),
              _navItem(3, "assets/icons/Bidswap-navBar.svg", "Bidswap"),
              _navItem(4, "assets/icons/Profile-navBar.svg", "Profile"),
            ],
          ),
        ),
        // Floating Action Button
        Positioned(
          top: -32.h,
          child: GestureDetector(
            onTap: () => Get.log("Add Clicked"),
            child: Container(
              width: 66.w,
              height: 66.w,
              decoration: BoxDecoration(
                color: const Color(0xFF8B9BFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B9BFF).withOpacity(0.4),
                    blurRadius: 25.r,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: const Color(0xFF0F0B1E), width: 5.w),
              ),
              child: Icon(Icons.add, color: Colors.black, size: 34.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navItem(int index, String iconPath, String label) {
    return Obx(() {
      bool isSelected = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.fastOutSlowIn,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 20.w : 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B9BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22.w,
                height: 22.w,
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.black : Colors.white70,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
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
