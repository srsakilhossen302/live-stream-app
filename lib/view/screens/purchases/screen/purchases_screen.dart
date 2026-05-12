import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/purchases_controller.dart';
import '../model/purchase_model.dart';

class PurchasesScreen extends GetView<PurchasesController> {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PurchasesController());
    return CustomBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Center(
                child: Text(
                  "My Purchases",
                  style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            
            // Filter Tabs
            SizedBox(
              height: 52.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: controller.tabs.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isSelected = controller.selectedTab.value == index;
                    return GestureDetector(
                      onTap: () => controller.changeTab(index),
                      child: Container(
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.symmetric(horizontal: 26.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF1E1E2C).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          controller.tabs[index],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF0F0B1E) : Colors.white38,
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
            
            // Orders List
            Expanded(
              child: Obx(() => ListView.builder(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 120.h),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.purchases.length,
                itemBuilder: (context, index) {
                  final order = controller.purchases[index];
                  return _buildOrderCard(order);
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(PurchaseModel order) {
    final isInTransit = order.status == OrderStatus.inTransit;
    final isDelivered = order.status == OrderStatus.delivered;
    final isProcessing = order.status == OrderStatus.processing;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header (ID & Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ORDER ID", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800)),
                  Text(order.id, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          // Product Details
          Row(
            children: [
              Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(18.r),
                  image: DecorationImage(image: NetworkImage(order.image), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w800, height: 1.2)),
                    SizedBox(height: 4.h),
                    Text(order.curator, style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 14.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6.h),
                    Text(order.date, style: TextStyle(color: Colors.white24, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 28.h),
          const Divider(color: Colors.white10, thickness: 1),
          SizedBox(height: 24.h),
          
          // Price and Carrier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TOTAL PAID", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800)),
                  Text(order.price, style: TextStyle(color: isInTransit ? const Color(0xFFFF8BFF) : Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("CARRIER", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800)),
                  Text(order.carrier, style: TextStyle(color: isDelivered ? Colors.white : Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          
          // Bottom Actions
          if (isInTransit) ...[
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Tracking ID: ${order.trackingId}",
                      style: TextStyle(color: Colors.white54, fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.copy_rounded, color: const Color(0xFF8B9BFF), size: 16.sp),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _buildPrimaryButton("Track Order"),
          ] else if (isDelivered) ...[
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(child: _buildSecondaryButton("View Details")),
                SizedBox(width: 14.w),
                Expanded(child: _buildSecondaryButton("Support")),
              ],
            ),
          ] else if (isProcessing) ...[
            SizedBox(height: 28.h),
            _buildOutlineButton("Order Details"),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg = Colors.white.withOpacity(0.08);
    Color text = Colors.white54;
    String label = "PROCESSING";

    if (status == OrderStatus.inTransit) {
      bg = const Color(0xFF5D2EEF);
      text = Colors.white;
      label = "IN TRANSIT";
    } else if (status == OrderStatus.delivered) {
      bg = Colors.white.withOpacity(0.08);
      text = Colors.white54;
      label = "DELIVERED";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == OrderStatus.inTransit)
            Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: Icon(Icons.circle, color: Colors.white, size: 6.sp),
            ),
          Text(label, style: TextStyle(color: text, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B9BFF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          elevation: 0,
        ),
        child: Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildSecondaryButton(String text) {
    return SizedBox(
      height: 60.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E2C).withOpacity(0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          elevation: 0,
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(String text) {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800),
      ),
    );
  }
}
