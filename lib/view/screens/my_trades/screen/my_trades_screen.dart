import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import '../../../../global/widgets/custom_background.dart';
import '../../../../core/app_route.dart';
import '../../../../data/services/api_url.dart';
import '../controller/my_trades_controller.dart';
import '../model/my_trade_model.dart';
import '../../../../global/widgets/custom_shimmer.dart';

class MyTradesScreen extends GetView<MyTradesController> {
  const MyTradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyTradesController());
    return CustomBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  ),
                  Text(
                    "My Trades",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoute.notifications),
                    child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26.sp),
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white10, thickness: 1),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    _buildFilters(),
                    SizedBox(height: 32.h),
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Column(
                          children: List.generate(3, (index) => _buildTradeCardShimmer()),
                        );
                      }

                      if (controller.filteredTrades.isEmpty) {
                        return SizedBox(
                          height: 300.h,
                          child: Center(
                            child: Text(
                              "No trades found.",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: controller.filteredTrades.map((trade) => _buildMyTradeCard(trade)).toList(),
                      );
                    }),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Row(
        children: List.generate(controller.filters.length, (index) {
          return Expanded(
            child: Obx(() {
              final isSelected = controller.selectedFilter.value == index;
              return GestureDetector(
                onTap: () => controller.changeFilter(index),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF282C36) : Colors.transparent,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(
                    controller.filters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xff97A9FF),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
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

  Widget _buildMyTradeCard(MyTradeModel trade) {
    Color statusBgColor;
    Color statusTextColor = Colors.white;
    String statusText;
    
    switch (trade.status) {
      case MyTradeStatus.shipped:
        statusBgColor = const Color(0xFF2E1E5D);
        statusText = "SHIPPED";
        break;
      case MyTradeStatus.pending:
        statusBgColor = Colors.white.withOpacity(0.05);
        statusText = "PENDING";
        break;
      case MyTradeStatus.completed:
        statusBgColor = Colors.white.withOpacity(0.05);
        statusText = "COMPLETED";
        break;
    }

    final bool isCompleted = trade.status == MyTradeStatus.completed;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TRADE ID: #${trade.tradeId}",
                style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusTextColor, fontSize: 10.sp, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            trade.title,
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900, height: 1.3),
          ),
          SizedBox(height: 24.h),
          
          if (isCompleted) ...[
            // Completed Layout
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TRADER", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14.r,
                            backgroundColor: Colors.white10,
                            backgroundImage: (trade.traderAvatar != null && trade.traderAvatar!.isNotEmpty)
                                ? NetworkImage(trade.traderAvatar!)
                                : null,
                            child: (trade.traderAvatar == null || trade.traderAvatar!.isEmpty)
                                ? Icon(Icons.person, color: Colors.white24, size: 14.sp)
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Text(trade.traderName, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("DATE", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    SizedBox(height: 12.h),
                    Text(trade.date ?? "Oct 24, 2023", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildActionButton(
              "View Receipt",
              const Color(0xFF8B9BFF),
              Colors.black,
              fullWidth: true,
              onTap: () {
                final productMap = {
                  "title": trade.title,
                  "description": "Completed Barter Trade Deal. Swapped items successfully. Status: COMPLETED",
                  "category": "BARTER",
                  "condition": "Completed Deal",
                  "estValue": "N/A",
                  "images": [trade.item1Image, trade.item2Image],
                  "sellerId": {
                    "fullName": trade.traderName,
                    "image": trade.traderAvatar,
                    "rating": "4.9",
                    "address": "Verified Trader"
                  }
                };
                Get.toNamed('/trade_details', arguments: productMap);
              },
            ),
            SizedBox(height: 24.h),
            Container(
              height: 180.h,
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTradeItemImage(trade.item1Image, large: true),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SvgPicture.asset(
                      "assets/icons/Container1.svg",
                      width: 24.w,
                      colorFilter: const ColorFilter.mode(Color(0xFF8B9BFF), BlendMode.srcIn),
                    ),
                  ),
                  _buildTradeItemImage(trade.item2Image, large: true),
                ],
              ),
            ),
          ] else ...[
            // Active (Shipped/Pending) Layout
            Row(
              children: [
                _buildTradeItemImage(trade.item1Image, small: true),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: SvgPicture.asset(
                    "assets/icons/Container1.svg",
                    width: 16.w,
                    colorFilter: const ColorFilter.mode(Colors.white10, BlendMode.srcIn),
                  ),
                ),
                _buildTradeItemImage(trade.item2Image, small: true),
                const Spacer(),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Trader", style: TextStyle(color: Colors.white24, fontSize: 12.sp, fontWeight: FontWeight.w800)),
                      Text(trade.traderName, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            if (trade.status == MyTradeStatus.pending && trade.isUserSender == false) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      "Accept Trade",
                      const Color(0xFF8B9BFF),
                      const Color(0xFF0F0B1E),
                      onTap: () {
                        if (trade.rawObjectId != null) {
                          controller.acceptTradeOffer(trade.rawObjectId!);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (trade.rawObjectId != null) {
                          controller.declineTradeOffer(trade.rawObjectId!);
                        }
                      },
                      child: Container(
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Decline",
                          style: TextStyle(color: Colors.redAccent, fontSize: 15.sp, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
            if (trade.status == MyTradeStatus.shipped) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      "Complete Trade",
                      const Color(0xFF22C55E),
                      Colors.white,
                      onTap: () {
                        if (trade.rawObjectId != null) {
                          controller.completeTradeOffer(trade.rawObjectId!);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "View Trade",
                    const Color(0xFF1E1E2C),
                    Colors.white,
                    onTap: () {
                      final productMap = {
                        "title": trade.title,
                        "description": "Barter Trade Offer. Status: ${trade.status.name.toUpperCase()}",
                        "category": "BARTER",
                        "condition": "Negotiated Deal",
                        "estValue": "N/A",
                        "images": [trade.item1Image, trade.item2Image],
                        "sellerId": {
                          "fullName": trade.traderName,
                          "image": trade.traderAvatar,
                          "rating": "4.8",
                          "address": "Verified Trader"
                        }
                      };
                      Get.toNamed('/trade_details', arguments: productMap);
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoute.messageDetails,
                    arguments: {
                      "chatId": "mock_room_1",
                      "name": trade.traderName.startsWith('@') ? trade.traderName : "@${trade.traderName}",
                      "avatar": trade.traderAvatar,
                    },
                  ),
                  child: Container(
                    height: 56.h,
                    width: 64.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.all(18.r),
                    child: SvgPicture.asset(
                      "assets/icons/Messg-navbar.svg",
                      colorFilter: const ColorFilter.mode(Color(0xFF8B9BFF), BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTradeItemImage(String url, {bool small = false, bool large = false}) {
    double size = 120.w;
    if (small) size = 64.w;
    if (large) size = 100.w;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(small ? 16.r : 24.r),
      ),
      child: _buildTradeProductImage(url),
    );
  }

  Widget _buildTradeProductImage(String imgStr, {BoxFit fit = BoxFit.cover}) {
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

  Widget _buildActionButton(String text, Color bg, Color textCol, {bool fullWidth = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(color: textCol, fontSize: 15.sp, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildTradeCardShimmer() {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomShimmer.rectangular(height: 12.h, width: 120.w),
              CustomShimmer.rectangular(
                height: 24.h,
                width: 80.w,
                shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomShimmer.rectangular(height: 20.h, width: 220.w),
          SizedBox(height: 24.h),
          Row(
            children: [
              CustomShimmer.circular(width: 40.r, height: 40.r),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomShimmer.rectangular(height: 14.h, width: 100.w),
                  SizedBox(height: 6.h),
                  CustomShimmer.rectangular(height: 12.h, width: 60.w),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
