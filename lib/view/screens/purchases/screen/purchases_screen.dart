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
            // Custom Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18.sp),
                      ),
                    ),
                  ),
                  Text(
                    "My Purchases",
                    style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            SizedBox(
              height: 54.h,
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
                        margin: EdgeInsets.only(right: 14.w),
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF1E1E2C).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          controller.tabs[index],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF0F0B1E) : Colors.white54,
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
            
            // List of Orders
            Expanded(
              child: Obx(() => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.purchases.length,
                itemBuilder: (context, index) {
                  return _buildPurchaseCard(controller.purchases[index]);
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(PurchaseModel order) {
    Color statusBgColor = const Color(0xFF1E1E2C).withOpacity(0.8);
    Color statusTextColor = Colors.white60;
    String statusText = "PROCESSING";
    
    if (order.status == OrderStatus.inTransit) {
      statusBgColor = const Color(0xFF5D2EEF);
      statusTextColor = Colors.white;
      statusText = "IN TRANSIT";
    } else if (order.status == OrderStatus.delivered) {
      statusBgColor = Colors.white.withOpacity(0.08);
      statusTextColor = Colors.white54;
      statusText = "DELIVERED";
    } else if (order.status == OrderStatus.processing) {
      statusBgColor = Colors.white.withOpacity(0.08);
      statusTextColor = Colors.white54;
      statusText = "PROCESSING";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ORDER ID", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  Text(order.id, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (order.status == OrderStatus.inTransit)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Icon(Icons.circle, color: Colors.white, size: 8.sp),
                      ),
                    Text(
                      statusText,
                      style: TextStyle(color: statusTextColor, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 28.h),
          
          // Product Info
          Row(
            children: [
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  image: DecorationImage(image: NetworkImage(order.image), fit: BoxFit.cover),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.r, offset: Offset(0, 5.h)),
                  ],
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
          
          // Payment Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TOTAL PAID", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  Text(order.price, style: TextStyle(color: const Color(0xFFFF8BFF), fontSize: 24.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("CARRIER", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  Text(order.carrier, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          
          // Contextual Actions
          if (order.status == OrderStatus.inTransit) ...[
            SizedBox(height: 28.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Tracking ID: ${order.trackingId}",
                      style: TextStyle(color: Colors.white54, fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.copy_all_rounded, color: const Color(0xFF8B9BFF), size: 18.sp),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _buildActionButton("Track Order", const Color(0xFF8B9BFF), Colors.black),
          ] else if (order.status == OrderStatus.delivered) ...[
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(child: _buildOutlineButton("View Details")),
                SizedBox(width: 14.w),
                Expanded(child: _buildOutlineButton("Support")),
              ],
            ),
          ] else if (order.status == OrderStatus.processing) ...[
            SizedBox(height: 32.h),
            _buildOutlineButton("Order Details", isFullWidth: true),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color bgColor, Color textColor) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        ),
        child: Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildOutlineButton(String text, {bool isFullWidth = false}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 60.h,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          backgroundColor: Colors.white.withOpacity(0.03),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
