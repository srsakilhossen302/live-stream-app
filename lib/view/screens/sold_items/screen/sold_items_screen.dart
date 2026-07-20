import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/app_route.dart';
import '../../../../data/services/api_url.dart';
import '../../../../global/widgets/custom_background.dart';
import '../../../../global/widgets/custom_bottom_navbar.dart';
import '../../purchases/model/purchase_model.dart';
import '../controller/sold_items_controller.dart';

class SoldItemsScreen extends StatelessWidget {
  const SoldItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SoldItemsController());

    return CustomBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // App Bar Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: const BoxDecoration(
                            color: Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Sold Items",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 36.w),
                    ],
                  ),
                ),

                // Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Obx(() => Row(
                    children: List.generate(controller.tabs.length, (index) {
                      final isSelected = controller.selectedTab.value == index;
                      return GestureDetector(
                        onTap: () => controller.selectedTab.value = index,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 10.w),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF1E1E2C).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.white10,
                            ),
                          ),
                          child: Text(
                            controller.tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  )),
                ),

                SizedBox(height: 12.h),

                // Main Content List
                Expanded(
                  child: Obx(() {
                    final _ = controller.selectedTab.value;
                    final __ = controller.soldItems.length;
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF8B9BFF)));
                    }

                    final items = controller.filteredSoldItems;
                    if (items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: controller.fetchSoldItems,
                        color: const Color(0xFF8B9BFF),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: 400.h,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sell_outlined, color: Colors.white24, size: 64.sp),
                                SizedBox(height: 16.h),
                                Text(
                                  "No Sold Items Yet",
                                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Items you sell will appear here so you can update tracking.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.fetchSoldItems,
                      color: const Color(0xFF8B9BFF),
                      child: ListView.builder(
                        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 100.h, top: 8.h),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _buildSoldItemCard(context, items[index]);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),

            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNavbar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoldItemCard(BuildContext context, PurchaseModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Order ID & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ORDER ID", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2.h),
                  Text(item.id, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              _buildStatusBadge(item.status),
            ],
          ),

          SizedBox(height: 16.h),
          const Divider(color: Colors.white10),
          SizedBox(height: 16.h),

          // Product Info & Buyer Info
          Row(
            children: [
              _buildProductImage(item.image),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, color: const Color(0xFF8B9BFF), size: 14.sp),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            "Buyer: ${item.buyerName ?? item.curator}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 13.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Sold: ${item.date}",
                      style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Price & Shipping Breakdown
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TOTAL EARNED", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2.h),
                    Text(
                      item.price,
                      style: TextStyle(color: const Color(0xFF22C55E), fontSize: 18.sp, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("CARRIER", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2.h),
                    Text(
                      item.carrier,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Action Buttons: Update Status & Contact Buyer
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B9BFF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    onPressed: () {
                      Get.toNamed(AppRoute.trackOrder, arguments: item);
                    },
                    icon: Icon(Icons.edit_location_alt_rounded, size: 18.sp),
                    label: Text(
                      "Details & Update",
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                height: 48.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E2C),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  onPressed: () {
                    Get.toNamed(AppRoute.messageDetails, arguments: {
                      "chatId": item.buyerId != null && item.buyerId!.isNotEmpty ? "chat_${item.buyerId}" : "chat_buyer",
                      "name": item.buyerName ?? "@buyer",
                      "avatar": item.buyerAvatar ?? "",
                      "traderId": item.buyerId ?? "",
                      "orderId": item.id,
                      "productTitle": item.title,
                    });
                  },
                  icon: Icon(Icons.chat_bubble_outline_rounded, size: 18.sp, color: const Color(0xFF8B9BFF)),
                  label: Text(
                    "Chat",
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    final String formattedUrl = imageUrl.startsWith('http') || imageUrl.startsWith('data:image/')
        ? imageUrl
        : (imageUrl.isNotEmpty ? "${ApiUrl.imageBaseUrl}${imageUrl.startsWith('/') ? imageUrl : '/$imageUrl'}" : "");

    return Container(
      width: 76.w,
      height: 76.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: formattedUrl.isNotEmpty
          ? (formattedUrl.startsWith('data:image/')
              ? Image.memory(
                  base64Decode(formattedUrl.split(',').last),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackImage(),
                )
              : Image.network(
                  formattedUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackImage(),
                ))
          : _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFF1E1E2C),
      child: Center(
        child: Icon(
          Icons.sell_rounded,
          color: const Color(0xFF8B9BFF),
          size: 32.sp,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg = Colors.white10;
    Color text = Colors.white70;
    String label = "PROCESSING";

    if (status == OrderStatus.inTransit) {
      bg = const Color(0xFF5D2EEF);
      text = Colors.white;
      label = "SHIPPED";
    } else if (status == OrderStatus.delivered) {
      bg = const Color(0xFF22C55E).withValues(alpha: 0.2);
      text = const Color(0xFF22C55E);
      label = "DELIVERED";
    } else if (status == OrderStatus.cancelled) {
      bg = const Color(0xFFEF4444).withValues(alpha: 0.2);
      text = const Color(0xFFEF4444);
      label = "CANCELLED";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label, style: TextStyle(color: text, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }
}
