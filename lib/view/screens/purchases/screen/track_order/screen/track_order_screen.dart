import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../global/widgets/custom_background.dart';
import '../../../model/purchase_model.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PurchaseModel order = Get.arguments;
    return CustomBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                    ),
                  ),
                  Text(
                    "Order ${order.id}",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white10, thickness: 1),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    // Map Section
                    _buildMapSection(order),
                    
                    SizedBox(height: 32.h),
                    
                    // Status Card
                    _buildStatusCard(order),
                    
                    SizedBox(height: 32.h),
                    
                    // Journey Updates
                    Text("JOURNEY UPDATES", style: TextStyle(color: Colors.white54, fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    SizedBox(height: 24.h),
                    _buildJourneyTimeline(),
                    
                    SizedBox(height: 32.h),
                    
                    // Order Summary Card
                    _buildOrderSummaryCard(order),
                    
                    SizedBox(height: 32.h),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(child: _buildButton("View Receipt", const Color(0xFF8B9BFF), Colors.black)),
                        SizedBox(width: 16.w),
                        Expanded(child: _buildButton("Contact Seller", const Color(0xFF1E1E2C).withOpacity(0.9), Colors.white)),
                      ],
                    ),
                    
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(PurchaseModel order) {
    return Container(
      height: 240.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=2066&auto=format&fit=crop"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 24.w,
            bottom: 24.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Color(0xff97A9FF), size: 6.sp),
                      SizedBox(width: 8.w),
                      Text("LIVE VIEW", style: TextStyle(color: Color(0xff97A9FF), fontSize: 10.sp, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  order.location ?? "Jersey City Distribution\nCenter",
                  style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900, height: 1.2),
                ),
              ],
            ),
          ),
          Positioned(
            right: 24.w,
            bottom: 24.h,
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFF8B9BFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFF8B9BFF).withOpacity(0.3), blurRadius: 15.r, spreadRadius: 2.r),
                ],
              ),
              child: Icon(Icons.near_me_rounded, color: Colors.black, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(PurchaseModel order) {
    return Container(
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(30.r),
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
                  Text("STATUS", style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                  Text(
                    order.status == OrderStatus.inTransit ? "In Transit" : 
                    order.status == OrderStatus.delivered ? "Delivered" : "Processing",
                    style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 24.sp, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("EST. DELIVERY", style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                  Text(order.estimatedDelivery ?? "Apr 23, 2026", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          SizedBox(height: 28.h),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 10.h,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(5.r)),
              ),
              Container(
                height: 10.h,
                width: 260.w,
                decoration: BoxDecoration(color: const Color(0xFF8B9BFF), borderRadius: BorderRadius.circular(5.r)),
              ),
              Positioned(
                left: 256.w,
                top: 0,
                child: Container(
                  height: 10.h,
                  width: 10.w,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SHIPPED", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800)),
              Text("ARRIVING SOON", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.w800)),
              Text("DELIVERED", style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyTimeline() {
    return Column(
      children: [
        _timelineItem(
          icon: Icons.local_shipping_rounded,
          title: "In Transit: Arrived at Jersey City",
          subtitle: "Arrived at Jersey City, NJ facility",
          time: "Today 10:25 AM",
          isActive: true,
          isFirst: true,
        ),
        _timelineItem(
          icon: Icons.inventory_2_rounded,
          title: "Shipped",
          subtitle: "Package left origin facility",
          time: "Apr 21",
          isActive: false,
        ),
        _timelineItem(
          icon: Icons.check_circle_outline_rounded,
          title: "Order Confirmed",
          subtitle: "Seller accepted your order",
          time: "Apr 21",
          isActive: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _timelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF5D2EEF).withOpacity(0.4) : Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isActive ? const Color(0xFF8B9BFF) : Colors.white24, size: 20.sp),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.w,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
            ],
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900))),
                      Text(time, style: TextStyle(color: const Color(0xFF8B9BFF).withOpacity(0.7), fontSize: 10.sp, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(subtitle, style: TextStyle(color: Colors.white24, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(PurchaseModel order) {
    return Container(
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(image: NetworkImage(order.image), fit: BoxFit.cover),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.r),
                  ],
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id, style: TextStyle(color: Color(0xffAC8AFF), fontSize: 11.sp, fontWeight: FontWeight.w800)),
                    Text(order.title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          const Divider(color: Colors.white10, thickness: 1),
          SizedBox(height: 24.h),
          _summaryRow("Item", "\$${order.itemPrice?.toStringAsFixed(2) ?? "115.00"}"),
          _summaryRow("Shipping", "\$${order.shippingPrice?.toStringAsFixed(2) ?? "15.00"}"),
          _summaryRow("Taxes", "\$${order.taxes?.toStringAsFixed(2) ?? "0.00"}"),
          _summaryRow("Processing Fee", "\$${order.processingFee?.toStringAsFixed(2) ?? "0.00"}"),
          _summaryRow("Buyer Contribution", "\$${order.buyerContribution?.toStringAsFixed(2) ?? "0.05"}", isHighlight: true),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL PAID", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
              Text("\$${order.totalPaid?.toStringAsFixed(2) ?? "130.05"}", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 26.sp, fontWeight: FontWeight.w900)),
            ],
          ),
          SizedBox(height: 28.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.white24, fontSize: 11.sp, height: 1.5),
                children: [
                  const TextSpan(text: "No platform markup added... \$0.05 contribution supports "),
                  TextSpan(
                    text: "Better Futures Foundation.",
                    style: TextStyle(color: const Color(0xFFFF8BFF), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isHighlight ? const Color(0xFFFF8BFF) : Colors.white38, fontSize: 15.sp, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: isHighlight ? const Color(0xFFFF8BFF) : Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color bg, Color textCol) {
    return SizedBox(
      height: 60.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textCol,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          elevation: 0,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
