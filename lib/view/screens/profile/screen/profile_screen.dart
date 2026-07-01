import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/app_route.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/profile_controller.dart';
import '../../../../data/services/api_url.dart';

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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

                    // Profile Info — Facebook-style cover
                    _buildProfileHeader(),

                    SizedBox(height: 24.h),

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
    return Obx(() {
      final coverUrl = controller.coverPhotoUrl.value;
      final profileUrl = controller.profileImageUrl.value;

      if (controller.isLoading.value && controller.name.value == "User Name") {
        return SizedBox(
          height: 300.h,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B9BFF)),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Photo Banner
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Cover image / placeholder
              GestureDetector(
                onTap: () => _showImagePickerSheet(isCover: true),
                child: Container(
                  width: double.infinity,
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF11111E),
                    image: coverUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(coverUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: coverUrl.isEmpty
                        ? const LinearGradient(
                            colors: [Color(0xFF0D0D1A), Color(0xFF1A1040)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: coverUrl.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.white38,
                                size: 28.sp,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              "Add Cover Photo",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              // Edit cover button (top-right)
              if (coverUrl.isNotEmpty)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: () => _showImagePickerSheet(isCover: true),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "Edit Cover",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Avatar overlapping the bottom edge of the cover
              Positioned(
                bottom: -48.h,
                left: 20.w,
                child: GestureDetector(
                  onTap: () => _showImagePickerSheet(isCover: false),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0D0D1A),
                            width: 4,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(48.r),
                          child: profileUrl.isNotEmpty
                              ? Image.network(
                                  profileUrl,
                                  width: 96.r,
                                  height: 96.r,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      CircleAvatar(
                                        radius: 48.r,
                                        backgroundColor: Colors.white10,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white24,
                                          size: 40.sp,
                                        ),
                                      ),
                                )
                              : CircleAvatar(
                                  radius: 48.r,
                                  backgroundColor: Colors.white10,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white24,
                                    size: 40.sp,
                                  ),
                                ),
                        ),
                      ),
                      // Positioned(
                      //   bottom: 4.h,
                      //   right: 4.w,
                      //   child: Container(
                      //     padding: EdgeInsets.all(6.r),
                      //     decoration: const BoxDecoration(
                      //       color: Color(0xFF8B9BFF),
                      //       shape: BoxShape.circle,
                      //     ),
                      //     child: Icon(
                      //       Icons.camera_alt,
                      //       color: Colors.black,
                      //       size: 13.sp,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Space so content doesn't collide with the overlapping avatar
          SizedBox(height: 56.h),

          // Name, handle, bio
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.name.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          controller.username.value,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    // Verified badge
                    Obx(() {
                      if (!controller.isVerified.value) return const SizedBox.shrink();
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B9BFF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFF8B9BFF).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: const Color(0xFF8B9BFF),
                              size: 14.sp,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              "Verified",
                              style: TextStyle(
                                color: const Color(0xFF8B9BFF),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  controller.description.value,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
                // Rating pill
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161622),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars,
                        color: const Color(0xFFFF8BFF),
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "${controller.rating.value.toStringAsFixed(1)}/10",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "${controller.reviewsCount.value} REVIEWS",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showImagePickerSheet({required bool isCover}) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Update ${isCover ? 'Cover' : 'Profile'} Photo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceItem(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    controller.updateImage(
                      ImageSource.camera,
                      isCover: isCover,
                    );
                  },
                ),
                _buildSourceItem(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    controller.updateImage(
                      ImageSource.gallery,
                      isCover: isCover,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFF8B9BFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF8B9BFF), size: 32.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  void _showCoverOptions() {
    _showImagePickerSheet(isCover: true);
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("ACTIVE", "${controller.activeCount.value}", const Color(0xFF8B9BFF)),
          Container(height: 30.h, width: 1, color: Colors.white10),
          _buildStatItem("SOLD ITEM", "${controller.soldCount.value}", const Color(0xFFFF8BFF)),
        ],
      )),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
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
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
      ),
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
                    color: isSelected
                        ? const Color(0xFF282C36)
                        : Colors.transparent,
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
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 200.h,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B9BFF)),
          ),
        );
      }
      
      if (controller.userListings.isEmpty) {
        return SizedBox(
          height: 200.h,
          child: Center(
            child: Text(
              "No listings posted yet.",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }

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
          itemCount: controller.userListings.length,
          itemBuilder: (context, index) {
            final item = controller.userListings[index];
            final title = item['title'] ?? "";
            final priceVal = item['buyNowPrice'] ?? item['estValue'] ?? 0;
            final price = "\$${priceVal.toString()}";

            String imageUrl = "";
            final imagesList = item['images'];
            if (imagesList != null && imagesList is List && imagesList.isNotEmpty) {
              final imagePath = imagesList[0].toString();
              imageUrl = imagePath.startsWith('http')
                  ? imagePath
                  : "${ApiUrl.imageBaseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}";
            }

            final isLive = item['status'] == 'live' || item['status'] == 'active';
            final isSold = item['status'] == 'sold' || item['isSold'] == true;
            final hasTrade = item['allowTrade'] == true;

            return _buildListingCard(
              title,
              price,
              imageUrl,
              isLive: isLive,
              hasTrade: hasTrade,
              isSold: isSold,
            );
          },
        ),
      );
    });
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
                  final isSelected =
                      controller.selectedActivityFilter.value == index;
                  return GestureDetector(
                    onTap: () => controller.changeActivityFilter(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B9BFF)
                            : const Color(0xFF161622),
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
        Obx(() {
          if (controller.isActivityLoading.value) {
            return SizedBox(
              height: 200.h,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B9BFF)),
              ),
            );
          }

          final isPurchases = controller.selectedActivityFilter.value == 1;
          final List<dynamic> currentList = isPurchases 
              ? controller.purchasesList 
              : controller.notificationsList;

          if (currentList.isEmpty) {
            return SizedBox(
              height: 200.h,
              child: Center(
                child: Text(
                  isPurchases ? "No purchases made yet." : "No activity logs available.",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: List.generate(currentList.length, (index) {
                final item = currentList[index];
                
                String svgPath = "assets/icons/New Message.svg";
                String title = "";
                String subtitle = "";
                String timeAgo = "";

                if (isPurchases) {
                  svgPath = "assets/icons/Purchase Made.svg";
                  title = "Purchase Made";
                  final product = item['productId'];
                  final productTitle = (product is Map) ? (product['title'] ?? 'Item') : 'Item';
                  subtitle = "You bought $productTitle";
                  timeAgo = item['createdAt'] != null 
                      ? _formatTimestamp(item['createdAt'].toString())
                      : "Recently";
                } else {
                  final type = item['type'] ?? "";
                  if (type.toString().toLowerCase().contains('order')) {
                    svgPath = "assets/icons/Order Delivered.svg";
                  } else if (type.toString().toLowerCase().contains('trade')) {
                    svgPath = "assets/icons/Trade Completed.svg";
                  } else {
                    svgPath = "assets/icons/New Message.svg";
                  }
                  title = item['title'] ?? "Alert";
                  subtitle = item['text'] ?? item['message'] ?? "";
                  timeAgo = item['createdAt'] != null
                      ? _formatTimestamp(item['createdAt'].toString())
                      : "Just now";
                }

                return _buildActivityItem(
                  svgPath: svgPath,
                  title: title,
                  subtitle: subtitle,
                  time: timeAgo,
                  isFirst: index == 0,
                  isLast: index == currentList.length - 1,
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final difference = DateTime.now().difference(dateTime);
      if (difference.inMinutes < 60) {
        return "${difference.inMinutes}m ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours}h ago";
      } else {
        return "${difference.inDays}d ago";
      }
    } catch (_) {
      return "Recently";
    }
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
                decoration: const BoxDecoration(
                  color: Color(0xFF161622),
                  shape: BoxShape.circle,
                ),
                child: svgPath != null
                    ? SvgPicture.asset(
                        svgPath,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFF8BFF),
                          BlendMode.srcIn,
                        ),
                      )
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
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
            trailing: Obx(
              () => Text(
                controller.username.value,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 24.w),
        //   child: Container(
        //     width: double.infinity,
        //     height: 80.h,
        //     decoration: BoxDecoration(
        //       color: const Color(0xFF1A0A10),
        //       borderRadius: BorderRadius.circular(32.r),
        //       border: Border.all(color: Colors.white.withOpacity(0.05)),
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Icon(Icons.logout_rounded, color: const Color(0xFFFF4B6E), size: 24.sp),
        //         SizedBox(width: 12.w),
        //         Text(
        //           "Logout",
        //           style: TextStyle(color: const Color(0xFFFF4B6E), fontSize: 16.sp, fontWeight: FontWeight.w900),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
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
            style: TextStyle(
              color: Colors.white24,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF11111A),
            borderRadius: BorderRadius.circular(32.r),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required String svgPath,
    required String title,
    bool showArrow = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
        child: Row(
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24.w,
              colorFilter: const ColorFilter.mode(
                Color(0xFF8B9BFF),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(
    String title,
    String price,
    String imageUrl, {
    bool isLive = false,
    bool hasTrade = false,
    bool isSold = false,
  }) {
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r),
                    ),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white24,
                            size: 32,
                          ),
                        )
                      : null,
                ),
                if (isLive)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B9BFF),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "LIVE",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isSold)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          "SOLD",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: const Color(0xFF8B9BFF),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (hasTrade)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E1E5D),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "TRADE",
                          style: TextStyle(
                            color: const Color(0xFF8B9BFF),
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w900,
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
    );
  }
}
