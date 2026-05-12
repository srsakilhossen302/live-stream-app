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
          height: 90.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF161622),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.r),
              topRight: Radius.circular(40.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20.r,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, "assets/icons/Home-navBar.svg", "Home"),
              _navItem(1, "assets/icons/Purchases-navBar.svg", "Shop"),
              SizedBox(width: 50.w), // Gap for FAB
              _navItem(2, "assets/icons/Discover-navBar.svg", "Find"),
              _navItem(3, "assets/icons/Bidswap-navBar.svg", "Swap"),
              _navItem(4, "assets/icons/Profile-navBar.svg", "User"),
            ],
          ),
        ),
        // Floating Action Button
        Positioned(
          top: -30.h,
          child: GestureDetector(
            onTap: () => Get.log("Add Clicked"),
            child: Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: const Color(0xFF8B9BFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B9BFF).withOpacity(0.4),
                    blurRadius: 20.r,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: const Color(0xFF0F0B1E), width: 4.w),
              ),
              child: Icon(Icons.add, color: Colors.black, size: 32.sp),
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
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 14.w : 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B9BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.black : Colors.white60,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
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
