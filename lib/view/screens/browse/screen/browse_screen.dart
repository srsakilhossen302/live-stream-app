import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/browse_controller.dart';
import '../model/category_model.dart';

class BrowseScreen extends GetView<BrowseController> {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BrowseController());
    return CustomBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: GestureDetector(
                  //     onTap: () => Get.back(),
                  //     child: Container(
                  //       padding: EdgeInsets.all(8.r),
                  //       decoration: BoxDecoration(
                  //         color: Colors.white.withOpacity(0.05),
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
                  //     ),
                  //   ),
                  // ),
                  Text(
                    "Browse",
                    style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop"),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white10, thickness: 1),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 28.h),
                    
                    // Search Bar
                    _buildSearchBar(),
                    
                    SizedBox(height: 32.h),
                    
                    // Filters
                    _buildFilters(),
                    
                    SizedBox(height: 32.h),
                    
                    // Category List
                    Obx(() => Column(
                      children: controller.categories.map((cat) => _buildCategoryCard(cat)).toList(),
                    )),
                    
                    SizedBox(height: 120.h), // Space for navbar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white, size: 24.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: "Search deals & more",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 16.sp),
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.tune_rounded, color: Colors.white, size: 22.sp),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.filters.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == index;
            return GestureDetector(
              onTap: () => controller.changeFilter(index),
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Text(
                  controller.filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white38,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      height: 220.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                category.image,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(28.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title.replaceAll(" & ", " &\n"),
                    style: TextStyle(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.w900, height: 1.1),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    category.subtitle,
                    style: TextStyle(color: Colors.white38, fontSize: 13.sp, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            // Live Badge
            Positioned(
              right: 24.w,
              bottom: 24.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E1E5D),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: const Color(0xFFAC8AFF), size: 6.sp),
                    SizedBox(width: 10.w),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.liveCount.split(" ")[0],
                          style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w900, height: 1),
                        ),
                        Text(
                          "Live",
                          style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.w800, height: 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
