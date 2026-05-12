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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
                  ),
                  const Spacer(),
                  Text(
                    "My Purchases",
                    style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  SizedBox(width: 40.w), // Balance
                ],
              ),
            ),
            
            // Tabs
            SizedBox(
              height: 50.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.tabs.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isSelected = controller.selectedTab.value == index;
                    return GestureDetector(
                      onTap: () => controller.changeTab(index),
                      child: Container(
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF1E1E2C).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          controller.tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white54,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // List
            Expanded(
              child: Obx(() => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: controller.purchases.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(controller.purchases[index]);
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(PurchaseModel order) {
    Color statusColor = const Color(0xFF8B9BFF);
    String statusText = "PROCESSING";
    
    if (order.status == OrderStatus.inTransit) {
      statusColor = const Color(0xFF5D2EEF);
      statusText = "IN TRANSIT";
    } else if (order.status == OrderStatus.delivered) {
      statusColor = Colors.white.withOpacity(0.1);
      statusText = "DELIVERED";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ORDER ID", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  Text(order.id, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    if (order.status == OrderStatus.inTransit)
                      const Padding(
                        padding: EdgeInsets.only(right: 6.0),
                        child: Icon(Icons.circle, color: Colors.white, size: 8),
                      ),
                    Text(
                      statusText,
                      style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          Row(
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(image: NetworkImage(order.image), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    Text(order.curator, style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4.h),
                    Text(order.date, style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          const Divider(color: Colors.white10),
          SizedBox(height: 16.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TOTAL PAID", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  Text(order.price, style: TextStyle(color: const Color(0xFFCC8BFF), fontSize: 20.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("CARRIER", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  Text(order.carrier, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          
          if (order.status == OrderStatus.inTransit) ...[
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Tracking ID: ${order.trackingId}",
                      style: TextStyle(color: Colors.white60, fontSize: 12.sp, fontFamily: 'Monospace'),
                    ),
                  ),
                  Icon(Icons.copy_rounded, color: const Color(0xFF8B9BFF), size: 16.sp),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B9BFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                ),
                child: Text("Track Order", style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
          
          if (order.status == OrderStatus.delivered) ...[
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white10),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    ),
                    child: Text("View Details", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white10),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    ),
                    child: Text("Support", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  ),
                ),
              ],
            ),
          ],
          
          if (order.status == OrderStatus.processing) ...[
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                ),
                child: Text("Order Details", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
