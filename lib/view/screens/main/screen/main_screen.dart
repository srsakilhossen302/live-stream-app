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
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0B1E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.r),
              topRight: Radius.circular(40.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30.r,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(0, "assets/icons/Home-navBar.svg", "Home"),
              _navItem(1, "assets/icons/Purchases-navBar.svg", "Shop"),
              // Center item Discover needs more space since it's directly under FAB
              _navItem(2, "assets/icons/Discover-navBar.svg", "Discover"), 
              _navItem(3, "assets/icons/Bidswap-navBar.svg", "Swap"),
              _navItem(4, "assets/icons/Profile-navBar.svg", "User"),
            ],
          ),
        ),
        // Floating Action Button - Moved higher to avoid overlap
        Positioned(
          top: -45.h, // Moved up from -32h
          child: GestureDetector(
            onTap: () => Get.log("Add Clicked"),
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFF8B9BFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B9BFF).withOpacity(0.5),
                    blurRadius: 25.r,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: const Color(0xFF0F0B1E), width: 6.w),
              ),
              child: Icon(Icons.add, color: Colors.black, size: 38.sp),
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
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 16.w : 10.w, vertical: 12.h),
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
