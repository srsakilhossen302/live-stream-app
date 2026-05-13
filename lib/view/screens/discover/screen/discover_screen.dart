import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/discover_controller.dart';
class DiscoverScreen extends GetView<DiscoverController> {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DiscoverController());
    return CustomBackground(
      child: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
                  ),
                  Text(
                    "Discover",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Skip",
                    style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      "Explore live streams and\ntrending categories",
                      style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    SizedBox(height: 24.h),

                    // Search Bar
                    _buildSearchBar(),
                    SizedBox(height: 24.h),

                    // Filters
                    _buildFilters(),
                    SizedBox(height: 32.h),

                    // Featured Section
                    _buildSectionHeader("Featured", onSeeAll: () {}),
                    SizedBox(height: 20.h),
                    _buildFeaturedCard(),
                    
                    SizedBox(height: 40.h),

                    // Available for Trade Section
                    _buildSectionHeader("Available for Trade", showFilter: true),
                    SizedBox(height: 20.h),
                    _buildTradeListItem(
                      "Vintage Pokémon Card Pack",
                      "EST. VALUE \$200",
                      "LOOKING FOR Equal value cards",
                      "https://images.unsplash.com/photo-1613771404721-1f92d799e49f?q=80&w=1000&auto=format&fit=crop",
                      "NEAR MINT",
                    ),
                    
                    SizedBox(height: 40.h),

                    // Trending Tags
                    Text(
                      "Trending Tags",
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    _buildTrendingTags(),

                    SizedBox(height: 32.h),

                    // Grid Section
                    Row(
                      children: [
                        Expanded(child: _buildGridCard("Top Sellers", showAvatars: true)),
                        SizedBox(width: 16.w),
                        Expanded(child: _buildGridCard("Upcoming Shows", subtitle: "24 Shows Today", icon: Icons.calendar_today_outlined)),
                      ],
                    ),
                    
                    SizedBox(height: 120.h), // Space for bottom navbar
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
      height: 58.h,
      decoration: BoxDecoration(
        color: const Color(0xFF161622).withOpacity(0.5),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
    return Obx(() => Row(
      children: List.generate(controller.filters.length, (index) {
        final isSelected = controller.selectedFilter.value == index;
        return GestureDetector(
          onTap: () => controller.changeFilter(index),
          child: Container(
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF161622).withOpacity(0.5),
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Text(
              controller.filters[index],
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white38,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    ));
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll, bool showFilter = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              "SEE ALL",
              style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        if (showFilter)
          Icon(Icons.tune_rounded, color: Colors.white38, size: 20.sp),
      ],
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      height: 380.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1552346154-21d32810aba3?q=80&w=1000&auto=format&fit=crop"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF8B9BFF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFF8B9BFF).withOpacity(0.5)),
              ),
              child: Text(
                "BOOSTED TRADE",
                style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Jordan 1 Retro High '85",
              style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              "Starting Est. \$1,200",
              style: TextStyle(color: Colors.white38, fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B9BFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
                ),
                child: Text(
                  "Inquire Trade",
                  style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeListItem(String title, String val, String lookingFor, String img, String tag) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              image: DecorationImage(image: NetworkImage(img), fit: BoxFit.contain),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D3A),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 9.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  val,
                  style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                Text(
                  lookingFor,
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.chevron_right, color: Colors.white38, size: 24.sp),
        ],
      ),
    );
  }

  Widget _buildTrendingTags() {
    final tags = ["#charizard", "#travisscott", "#rolex", "#comic-con", "#supreme"];
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: tags.map((tag) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF161622).withOpacity(0.5),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Text(
          tag,
          style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500),
        ),
      )).toList(),
    );
  }

  Widget _buildGridCard(String title, {String? subtitle, IconData? icon, bool showAvatars = false}) {
    return Container(
      height: 220.h,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622).withOpacity(0.5),
        borderRadius: BorderRadius.circular(30.r),
        border: title == "Upcoming Shows" ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (showAvatars)
            Row(
              children: [
                _buildAvatarStack(),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle),
                  child: Text("+12", style: TextStyle(color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          if (subtitle != null)
            Row(
              children: [
                Icon(icon, color: const Color(0xFF8B9BFF), size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  subtitle,
                  style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 60.w,
      height: 30.h,
      child: Stack(
        children: [
          CircleAvatar(radius: 15.r, backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop")),
          Positioned(left: 20.w, child: CircleAvatar(radius: 15.r, backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop"))),
        ],
      ),
    );
  }
}
