import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/app_route.dart';
import '../../../../global/widgets/custom_background.dart';
import '../../main/controller/main_controller.dart';
import '../controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return CustomBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                "WELCOME BACK",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Text(
                    "Hello, Alex 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // Search Bar
              GestureDetector(
                onTap: () => Get.find<MainController>().changeIndex(2),
                child: Container(
                  height: 58.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161622),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white38, size: 24.sp),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          "Search auctions, items...",
                          style: TextStyle(color: Colors.white24, fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              // Category Chips
              SizedBox(
                height: 48.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected =
                          controller.selectedCategoryIndex.value == index;
                      return GestureDetector(
                        onTap: () => controller.onCategorySelected(index),
                        child: Container(
                          margin: EdgeInsets.only(right: 12.w),
                          padding: EdgeInsets.symmetric(horizontal: 28.w),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF8B9BFF)
                                : const Color(0xFF1E1E2C).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Text(
                            controller.categories[index],
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0F0B1E)
                                  : Colors.white60,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),

              SizedBox(height: 32.h),

              // Featured Card
              Container(
                height: 440.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.r),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/image.png"),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(28.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildSmallBadge("LIVE", const Color(0xFFFF5252)),
                          SizedBox(width: 10.w),
                          _buildSmallBadge(
                            "4.2K",
                            Colors.black.withOpacity(0.4),
                            icon: Icons.visibility_outlined,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1.5.w,
                              ),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  "https://i.pravatar.cc/150?u=9",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CURATED BY",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                "VintageVault_Pro",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        "Rare 1980s Tech Drop: Unopened Grail Consoles & Limited Prototypes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 60.h,
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoute.liveStream),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B9BFF),
                            foregroundColor: const Color(0xFF0F0B1E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_fill_rounded,
                                size: 28.sp,
                                color: const Color(0xFF0F0B1E),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                "Join Stream",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18.sp,
                                  color: const Color(0xFF0F0B1E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Live Now Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Live Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "Bidding wars in progress",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "SEE ALL",
                      style: TextStyle(
                        color: const Color(0xFF8B9BFF),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Live Now Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18.w,
                  mainAxisSpacing: 18.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: controller.liveItems.length,
                itemBuilder: (context, index) {
                  final item = controller.liveItems[index];
                  return _buildLiveCard(item, index);
                },
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color bgColor, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (text == "LIVE")
            Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Icon(Icons.circle, color: Colors.white, size: 8.sp),
            ),
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Icon(icon, color: Colors.white, size: 12.sp),
            ),
          Text(
            text,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(LiveItemModel item, int index) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoute.liveStream, arguments: item),
      child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(item.image, fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSmallBadge("LIVE", const Color(0xFFFF4B67)),
                      const Spacer(),
                      _buildSmallBadge(
                        item.viewers,
                        Colors.black.withOpacity(0.4),
                        icon: Icons.visibility_outlined,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (index == 0)
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2C).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Text(
                          "LIVE PREVIEW",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10.r,
                        backgroundImage: const NetworkImage(
                          "https://i.pravatar.cc/150?u=avatar",
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          item.curator,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
