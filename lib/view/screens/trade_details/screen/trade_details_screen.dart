import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../../../global/widgets/custom_background.dart';
import '../controller/trade_details_controller.dart';
import '../../discover/controller/discover_controller.dart';
import '../../../../data/services/api_url.dart';
import '../../../../data/helpers/shared_prefe.dart';

class TradeDetailsScreen extends GetView<TradeDetailsController> {
  const TradeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final detailsController = Get.put(TradeDetailsController());
    if (Get.arguments != null && Get.arguments is Map) {
      detailsController.product.assignAll(Map<String, dynamic>.from(Get.arguments));
      detailsController.currentImageIndex.value = 0;
    }
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
                            name: (product['lookingFor'] ?? "Equal Value Swaps").toString(),
                            subName: "Estimated Value: \$${product['estValue'] ?? estValue}",
                            isOffering: false,
                            badge: "ANY CATEGORY",
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
                          _buildSimilarTrades(product),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            // Floating Bottom Action Bar
            Obx(() {
              final product = controller.product;
              if (product.isEmpty) return const SizedBox.shrink();
              
              final currentUserId = SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
              final seller = product['sellerId'];
              final sellerId = (seller is Map) ? (seller['_id'] ?? seller['id'] ?? "") : seller.toString();
              final isOwner = currentUserId.isNotEmpty && currentUserId == sellerId;
              
              if (isOwner) return const SizedBox.shrink();
              
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.95),
                        Colors.black,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.toNamed('/make_offer'),
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E2C),
                              borderRadius: BorderRadius.circular(28.r),
                              border: Border.all(color: Colors.white10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Inquire Trade",
                              style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showPurchaseConfirmation(context, product),
                          child: Container(
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B9BFF),
                              borderRadius: BorderRadius.circular(28.r),
                            ),
                            alignment: Alignment.center,
                            child: controller.isOrdering.value
                                ? SizedBox(
                                    height: 20.h,
                                    width: 20.h,
                                    child: const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                  )
                                : Text(
                                    "Buy Now",
                                    style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w900),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPurchaseConfirmation(BuildContext context, Map<String, dynamic> product) {
    final title = product['title'] ?? "Product";
    final priceVal = product['buyNowPrice'] ?? product['estValue'] ?? "250";
    final price = "\$${priceVal.toString()}";

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: const Color(0xFF11111A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            Text("Confirm Purchase", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 16.h),
            Text("Are you sure you want to buy this item instantly?", style: TextStyle(color: Colors.white38, fontSize: 14.sp, fontWeight: FontWeight.w500)),
            SizedBox(height: 24.h),
            
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(24.r)),
              child: Row(
                children: [
                  Container(
                    width: 60.r,
                    height: 60.r,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12.r)),
                    child: _buildDetailsProductImage(product['images']?.first?.toString() ?? ""),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4.h),
                        Text("Price: $price", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 13.sp, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 56.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(28.r)),
                      child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.buyProduct();
                    },
                    child: Container(
                      height: 56.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xFF8B9BFF), borderRadius: BorderRadius.circular(28.r)),
                      child: Text("Confirm Buy", style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDynamicImageGallery(Map<String, dynamic> product) {
    String galleryUrl = "https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=1000";
    final List? images = product['images'] as List?;
    if (images != null && images.isNotEmpty) {
      final path = images[0].toString();
      galleryUrl = (path.startsWith('http') || path.startsWith('data:image/'))
          ? path
          : "${ApiUrl.imageBaseUrl}${path.startsWith('/') ? path : '/$path'}";
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
    final Map<String, dynamic>? sellerMap = seller is Map ? Map<String, dynamic>.from(seller) : null;
    final name = sellerMap?['fullName'] ?? sellerMap?['name'] ?? "Julian_D";
    final rating = (sellerMap?['rating'] ?? "4.8").toString();
    final address = sellerMap?['address'] ?? "New York, NY";
    
    String avatarUrl = "";
    final sellerImage = (sellerMap?['profile'] ?? sellerMap?['image'] ?? sellerMap?['profileImageUrl'] ?? sellerMap?['avatar'])?.toString();
    if (sellerImage != null && sellerImage.isNotEmpty) {
      avatarUrl = (sellerImage.startsWith('http') || sellerImage.startsWith('data:image/'))
          ? sellerImage
          : "${ApiUrl.imageBaseUrl}${sellerImage.startsWith('/') ? sellerImage : '/$sellerImage'}";
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/trader_profile', arguments: {
        "id": sellerMap?['_id'] ?? sellerMap?['id'] ?? (seller is String ? seller : ''),
        "name": name,
        "avatar": avatarUrl.isNotEmpty ? avatarUrl : "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop",
        "bio": sellerMap?['bio'] ?? sellerMap?['description'] ?? '',
      }),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(24.r)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: Colors.white10,
              child: avatarUrl.isNotEmpty
                  ? ClipOval(
                      child: SizedBox(
                        width: 48.r,
                        height: 48.r,
                        child: _buildDetailsProductImage(avatarUrl),
                      ),
                    )
                  : Icon(Icons.person, color: Colors.white24, size: 24.sp),
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
                    Expanded(
                      child: Text(
                        subName,
                        style: TextStyle(color: Colors.white38, fontSize: 15.sp, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

  Widget _buildSimilarTrades(Map<String, dynamic> product) {
    final List<Map<String, dynamic>> similarItems = [];
    try {
      final discoverCtrl = Get.find<DiscoverController>();
      final String currentCategory = (product['category'] ?? "").toString();
      final String currentTitle = (product['title'] ?? "").toString();
      
      final matched = discoverCtrl.tradeMarketItems.where((item) {
        final raw = item['raw'];
        if (raw == null) return false;
        return raw['category']?.toString() == currentCategory && item['title'] != currentTitle;
      }).toList();

      if (matched.isNotEmpty) {
        similarItems.addAll(matched.take(3).cast<Map<String, dynamic>>());
      } else {
        similarItems.addAll(discoverCtrl.tradeMarketItems
            .where((item) => item['title'] != currentTitle)
            .take(3)
            .cast<Map<String, dynamic>>());
      }
    } catch (_) {}

    if (similarItems.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Text(
            "No similar trades found.",
            style: TextStyle(color: Colors.white24, fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: similarItems.map((item) {
          final title = item['title'].toString();
          final lookingFor = item['lookingFor'].toString();
          final value = item['value'].toString();
          final imgUrl = item['image'].toString();
          
          return GestureDetector(
            onTap: () {
              final detailsCtrl = Get.find<TradeDetailsController>();
              detailsCtrl.product.assignAll(Map<String, dynamic>.from(item['raw']));
              detailsCtrl.currentImageIndex.value = 0;
            },
            child: Container(
              width: 280.w,
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(24.r)),
              child: Row(
                children: [
                  Container(
                    width: 70.w,
                    height: 70.w,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: _buildDetailsProductImage(imgUrl),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4.h),
                        Text(lookingFor, style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 2.h),
                        Text(value, style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 11.sp, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
