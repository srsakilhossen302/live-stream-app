import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../../../global/widgets/custom_background.dart';
import '../controller/trade_details_controller.dart';
import '../../../../data/services/api_url.dart';

class TradeDetailsScreen extends GetView<TradeDetailsController> {
  const TradeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TradeDetailsController());
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
          title: Text("Trade Details", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: Stack(
          children: [
            Obx(() {
              final product = controller.product;
              
              final category = (product['category'] ?? "APPAREL").toString().toUpperCase();
              final condition = (product['condition'] ?? "BRAND NEW").toString().toUpperCase();
              final title = product['title'] ?? "Off-White Tee – Chicago Edition";
              final estValue = product['estValue'] ?? "250";
              final description = product['description'] ?? "Exclusive Chicago Edition drop. Kept in original packaging since release. Looking for a high-end timepiece trade specifically, but open to hearing other luxury offers in the watch category.";

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDynamicImageGallery(product),
                    
                    Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("$category • $condition", style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 1)),
                          SizedBox(height: 8.h),
                          Text(title, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900)),
                          
                          SizedBox(height: 32.h),
                          _buildDynamicTraderCard(product),
                          SizedBox(height: 32.h),
                          
                          _buildTradeBox(
                            title: "OFFERING",
                            name: title,
                            subName: "$condition condition",
                            isOffering: true,
                          ),
                          
                          Center(
                            child: Container(
                              height: 48.h,
                              width: 48.h,
                              margin: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF282C36),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10.r, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/icons/updaont.svg",
                                  width: 22.sp,
                                  height: 22.sp,
                                  colorFilter: const ColorFilter.mode(Color(0xFF8B9BFF), BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          
                          _buildTradeBox(
                            title: "LOOKING FOR",
                            name: product.isEmpty ? "Rolex Submariner Date" : "Luxury / Equal Value Swaps",
                            subName: product.isEmpty ? "\$5k-\$6k Range" : "Estimated Value: \$$estValue",
                            isOffering: false,
                            badge: product.isEmpty ? "TOP PRIORITY" : "ANY CATEGORY",
                          ),
                          
                          SizedBox(height: 32.h),
                          Text("DESCRIPTION", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          SizedBox(height: 16.h),
                          Text(
                            description,
                            style: TextStyle(color: Colors.white60, fontSize: 14.sp, height: 1.6, fontWeight: FontWeight.w500),
                          ),
                          
                          SizedBox(height: 32.h),
                          Text("VERIFICATION METHODS", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(child: _buildVerificationCard(null, "Platform Verified", "100% Secure Auth", iconData: Icons.shield_outlined)),
                              SizedBox(width: 16.w),
                              Expanded(child: _buildVerificationCard("assets/icons/Direct Trade-icons.svg", "Direct Trade", "Peer-to-peer risk")),
                            ],
                          ),
                          
                          SizedBox(height: 32.h),
                          _buildStatsRow(),
                          SizedBox(height: 32.h),
                          Text("SIMILAR TRADES", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          SizedBox(height: 16.h),
                          _buildSimilarTrades(),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicImageGallery(Map<String, dynamic> product) {
    String galleryUrl = "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=1000";
    final List? images = product['images'] as List?;
    if (images != null && images.isNotEmpty) {
      final path = images[0].toString();
      galleryUrl = path.startsWith('http') ? path : "${ApiUrl.imageBaseUrl}${path.startsWith('/') ? path : '/$path'}";
    }
    
    final estValue = product['estValue'] ?? "250";

    return Stack(
      children: [
        Container(
          height: 450.h,
          width: double.infinity,
          color: const Color(0xFFF5F5F5),
          child: _buildDetailsProductImage(galleryUrl, fit: BoxFit.contain),
        ),
        Positioned(
          top: 20.h,
          left: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadge("OPEN TRADE", const Color(0xFF8B9BFF)),
              SizedBox(height: 8.h),
              _buildBadge("\$$estValue EST. VALUE", Colors.black.withOpacity(0.8)),
            ],
          ),
        ),
        Positioned(
          bottom: 20.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20.r)),
              child: Obx(() => Text(
                "${controller.currentImageIndex.value == 0 ? 1 : controller.currentImageIndex.value} / ${controller.totalImages}",
                style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10.r)),
      child: Text(text, style: TextStyle(color: color == const Color(0xFF8B9BFF) ? Colors.black : Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildDynamicTraderCard(Map<String, dynamic> product) {
    final seller = product['sellerId'];
    final name = seller?['fullName'] ?? "Julian_D";
    final rating = seller?['rating'] ?? "4.8";
    final address = seller?['address'] ?? "New York, NY";
    
    String avatarUrl = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974";
    final sellerImage = seller?['image']?.toString();
    if (sellerImage != null && sellerImage.isNotEmpty) {
      avatarUrl = sellerImage.startsWith('http') ? sellerImage : "${ApiUrl.imageBaseUrl}${sellerImage.startsWith('/') ? sellerImage : '/$sellerImage'}";
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/trader_profile'),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(24.r)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: SizedBox(
                  width: 48.r,
                  height: 48.r,
                  child: _buildDetailsProductImage(avatarUrl),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                      SizedBox(width: 4.w),
                      Icon(Icons.verified, color: const Color(0xFF8B9BFF), size: 16.sp),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text("⭐ $rating • $address", style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 28.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeBox({required String title, required String name, required String subName, required bool isOffering, String? badge}) {
    // Exact colors from mockup
    final offeringColor = const Color(0xFF8B9BFF);
    final lookingForLabelColor = const Color(0xFFFF8BFF);
    final lookingForBarColor = const Color(0xFF9155FF); // Exact purple from mockup

    final primaryColor = isOffering ? offeringColor : lookingForBarColor;
    final labelColor = isOffering ? offeringColor : lookingForLabelColor;

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Stack(
        children: [
          // Vertical indicator bar - Perfect Pill shape
          Positioned(
            left: 0,
            top: 2.h,
            bottom: 2.h,
            child: Container(
              width: 6.w,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 28.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(color: labelColor, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    Icon(
                      isOffering ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: isOffering ? Colors.white70 : labelColor,
                      size: 26.sp,
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Text(name, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(subName, style: TextStyle(color: Colors.white38, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    if (badge != null) ...[
                      SizedBox(width: 14.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(color: const Color(0xFF2E1E5D), borderRadius: BorderRadius.circular(10.r)),
                        child: Text(badge, style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(String? svgPath, String title, String subtitle, {IconData? iconData}) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (svgPath != null)
            SvgPicture.asset(
              svgPath,
              width: 32.sp,
              height: 32.sp,
              colorFilter: const ColorFilter.mode(Color(0xFF8B9BFF), BlendMode.srcIn),
            )
          else if (iconData != null)
            Icon(iconData, color: const Color(0xFF8B9BFF), size: 32.sp),
          SizedBox(height: 16.h),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900)),
          SizedBox(height: 4.h),
          Text(subtitle, style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(24.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("12", "OFFERS"),
          _buildDivider(),
          _buildStatItem("3d", "ACTIVE"),
          _buildDivider(),
          _buildStatItem("~2h", "RESPONSE"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30.h, width: 1, color: Colors.white10);
  }

  Widget _buildSimilarTrades() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(3, (index) => Container(
          width: 280.w,
          margin: EdgeInsets.only(right: 16.w),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(24.r)),
          child: Row(
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1556906781-9a412961c28c?q=80&w=1000&auto=format&fit=crop"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("OW Logo Hoodie", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4.h),
                    Text("Looking for Yeezy", style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w700)),
                    Text("\$50 + \$100 Est.", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 11.sp, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
  Widget _buildDetailsProductImage(String imgStr, {BoxFit fit = BoxFit.cover}) {
    if (imgStr.isEmpty) {
      return Image.network(
        "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
        fit: fit,
      );
    }
    
    if (imgStr.startsWith('data:image/') && imgStr.contains('base64,')) {
      try {
        final base64Content = imgStr.split('base64,').last;
        final bytes = base64Decode(base64Content);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Image.network(
            "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
            fit: fit,
          ),
        );
      } catch (_) {
        return Image.network(
          "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
          fit: fit,
        );
      }
    }
    
    final cleanUrl = imgStr.startsWith('http')
        ? imgStr
        : "${ApiUrl.imageBaseUrl}${imgStr.startsWith('/') ? imgStr : '/$imgStr'}";

    return Image.network(
      cleanUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Image.network(
        "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
        fit: fit,
      ),
    );
  }
}
