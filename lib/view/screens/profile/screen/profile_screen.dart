import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../core/app_route.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return CustomBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  ),
                  Text(
                    "Profile",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    
                    // Profile Info
                    _buildProfileHeader(),
                    
                    SizedBox(height: 32.h),
                    
                    // Stats Row
                    _buildStatsRow(),
                    
                    SizedBox(height: 32.h),
                    
                    // Tabs
                    _buildTabBar(),
                    
                    SizedBox(height: 24.h),
                    
                    // Content Section
                    Obx(() {
                      if (controller.selectedTab.value == 1) {
                        return _buildActivityTab();
                      } else if (controller.selectedTab.value == 2) {
                        return _buildSettingsTab();
                      } else {
                        return _buildListingsGrid();
                      }
                    }),
                    
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF8B9BFF), width: 2),
              ),
              child: CircleAvatar(
                radius: 50.r,
                backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop"),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle),
              child: Icon(Icons.verified, color: Colors.black, size: 16.sp),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text("Julian Draxler", style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900)),
        SizedBox(height: 4.h),
        Text("@jdraxler_collector", style: TextStyle(color: Colors.white38, fontSize: 14.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            "Collector & trader of rare sneakers and vintage cards. Trusted deals only.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(20.r)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, color: const Color(0xFFFF8BFF), size: 18.sp),
              SizedBox(width: 8.w),
              Text("9.0/10", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900)),
              SizedBox(width: 8.w),
              Text("124 REVIEWS", style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("ACTIVE", "4", const Color(0xFF8B9BFF)),
          Container(height: 30.h, width: 1, color: Colors.white10),
          _buildStatItem("SOLD ITEM", "14", const Color(0xFFFF8BFF)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
        SizedBox(height: 8.h),
        Text(value, style: TextStyle(color: color, fontSize: 24.sp, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(32.r)),
      child: Row(
        children: List.generate(controller.tabs.length, (index) {
          return Expanded(
            child: Obx(() {
              final isSelected = controller.selectedTab.value == index;
              return GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF282C36) : Colors.transparent,
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: Text(
                    controller.tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white38,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildListingsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          if (index == 0) return _buildListingCard("Nike Dunk Low 'Retro'", "\$180", "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=1000&auto=format&fit=crop", isLive: true, hasTrade: true);
          if (index == 1) return _buildListingCard("Supreme Classic Tee", "\$85", "https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=1000&auto=format&fit=crop", isSold: true);
          if (index == 2) return _buildListingCard("Seiko Prospex 'Blue'", "\$420", "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=1000&auto=format&fit=crop", isLive: true);
          return _buildListingCard("Pokemon Charizard V", "\$1,200", "https://images.unsplash.com/photo-1613771404721-1f92d799e49f?q=80&w=1000&auto=format&fit=crop", isLive: true, hasTrade: true);
        },
      ),
    );
  }

  Widget _buildActivityTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-filters
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: List.generate(controller.activityFilters.length, (index) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Obx(() {
                  final isSelected = controller.selectedActivityFilter.value == index;
                  return GestureDetector(
                    onTap: () => controller.changeActivityFilter(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF161622),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Text(
                        controller.activityFilters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white38,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
        SizedBox(height: 32.h),
        
        // Activity List
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              _buildActivityItem(
                svgPath: "assets/icons/Order Delivered.svg",
                title: "Order Delivered",
                subtitle: "Your order #24891 has arrived",
                time: "2h ago",
                isFirst: true,
              ),
              _buildActivityItem(
                svgPath: "assets/icons/Trade Completed.svg",
                title: "Trade Completed",
                subtitle: "Trade with @user123 completed",
                time: "5h ago",
              ),
              _buildActivityItem(
                svgPath: "assets/icons/New Message.svg",
                title: "New Message",
                subtitle: "New message from @sellerX",
                time: "Yesterday",
              ),
              _buildActivityItem(
                svgPath: "assets/icons/Purchase Made.svg",
                title: "Purchase Made",
                subtitle: "You bought Pokémon Card Pack",
                time: "2d ago",
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    IconData? icon,
    String? svgPath,
    required String title,
    required String subtitle,
    required String time,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Icon
          Column(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(color: Color(0xFF161622), shape: BoxShape.circle),
                child: svgPath != null
                    ? SvgPicture.asset(svgPath, colorFilter: const ColorFilter.mode(Color(0xFFFF8BFF), BlendMode.srcIn))
                    : Icon(icon, color: const Color(0xFFFF8BFF), size: 22.sp),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
            ],
          ),
          SizedBox(width: 20.w),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                      Text(time, style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(subtitle, style: TextStyle(color: Colors.white38, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsSection("ACCOUNT", [
          _buildSettingsTile(
            svgPath: "assets/icons/Edit Profile.svg",
            title: "Edit Profile",
            showArrow: true,
            onTap: () => Get.toNamed(AppRoute.accountSettings),
          ),
          _buildSettingsTile(
            svgPath: "assets/icons/Username.svg",
            title: "Username",
            trailing: Text("@jdraxler_collector", style: TextStyle(color: Colors.white38, fontSize: 13.sp, fontWeight: FontWeight.w700)),
          ),
        ]),
        SizedBox(height: 32.h),
        _buildSettingsSection("PAYMENTS", [
          _buildSettingsTile(
            svgPath: "assets/icons/My Purchase.svg",
            title: "My Purchase",
            showArrow: true,
            onTap: () => Get.toNamed('/purchases'),
          ),
          _buildSettingsTile(
            svgPath: "assets/icons/My Trades.svg",
            title: "My Trades",
            showArrow: true,
            onTap: () => Get.toNamed('/my_trades'),
          ),
        ]),
        SizedBox(height: 32.h),
        _buildSettingsSection("SUPPORT", [
          _buildSettingsTile(
            svgPath: "assets/icons/Terms & Conditions.svg",
            title: "Terms & Conditions",
            showArrow: true,
            onTap: () => Get.toNamed(AppRoute.terms),
          ),
        ]),
        SizedBox(height: 48.h),
        
        // Logout Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            width: double.infinity,
            height: 80.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1A0A10),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: const Color(0xFFFF4B6E), size: 24.sp),
                SizedBox(width: 12.w),
                Text(
                  "Logout",
                  style: TextStyle(color: const Color(0xFFFF4B6E), fontSize: 16.sp, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 24.w, bottom: 16.h),
          child: Text(
            title,
            style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF11111A),
            borderRadius: BorderRadius.circular(32.r),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({required String svgPath, required String title, bool showArrow = false, Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
        child: Row(
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24.w,
              colorFilter: const ColorFilter.mode(Color(0xFF8B9BFF), BlendMode.srcIn),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ),
            if (trailing != null) trailing!,
            if (showArrow)
              Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(String title, String price, String imageUrl, {bool isLive = false, bool hasTrade = false, bool isSold = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                    image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  ),
                ),
                if (isLive)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(color: const Color(0xFF8B9BFF), borderRadius: BorderRadius.circular(8.r)),
                      child: Row(
                        children: [
                          Container(width: 6.r, height: 6.r, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                          SizedBox(width: 6.w),
                          Text("LIVE", style: TextStyle(color: Colors.black, fontSize: 9.sp, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                if (isSold)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.white12)),
                        child: Text("SOLD", style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 16.sp, fontWeight: FontWeight.w900)),
                    if (hasTrade)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(color: const Color(0xFF2E1E5D), borderRadius: BorderRadius.circular(6.r)),
                        child: Text("TRADE", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 8.sp, fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
