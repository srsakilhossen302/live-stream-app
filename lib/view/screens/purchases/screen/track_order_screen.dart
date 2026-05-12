import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../../purchases/model/purchase_model.dart';

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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Order #ORD-24891",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 24.w), // Balance
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map Section
                    _buildMapSection(),
                    
                    SizedBox(height: 32.h),
                    
                    // Status Card
                    _buildStatusCard(),
                    
                    SizedBox(height: 32.h),
                    
                    // Journey Updates
                    Text("JOURNEY UPDATES", style: TextStyle(color: Colors.white54, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    SizedBox(height: 20.h),
                    _buildJourneyTimeline(),
                    
                    SizedBox(height: 32.h),
                    
                    // Order Summary Card
                    _buildOrderSummaryCard(),
                    
                    SizedBox(height: 32.h),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(child: _buildButton("View Receipt", const Color(0xFF8B9BFF), Colors.black)),
                        SizedBox(width: 16.w),
                        Expanded(child: _buildButton("Contact Seller", const Color(0xFF1E1E2C), Colors.white)),
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

  Widget _buildMapSection() {
    return Container(
      height: 220.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=2066&auto=format&fit=crop"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
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
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: const Color(0xFF8B9BFF), size: 6.sp),
                      SizedBox(width: 6.w),
                      Text("LIVE VIEW", style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Jersey City Distribution\nCenter",
                  style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Positioned(
            right: 24.w,
            bottom: 24.h,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle),
              child: Icon(Icons.near_me_rounded, color: Colors.black, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(28.r),
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
                  Text("STATUS", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  Text("In Transit", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 24.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("EST. DELIVERY", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  Text("Apr 23, 2026", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 8.h,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4.r)),
              ),
              Container(
                height: 8.h,
                width: 200.w,
                decoration: BoxDecoration(color: const Color(0xFF8B9BFF), borderRadius: BorderRadius.circular(4.r)),
              ),
              Positioned(
                left: 196.w,
                top: 0,
                child: Container(
                  height: 8.h,
                  width: 8.w,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SHIPPED", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              Text("ARRIVING SOON", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.bold)),
              Text("DELIVERED", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold)),
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
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF5D2EEF).withOpacity(0.5) : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isActive ? const Color(0xFF8B9BFF) : Colors.white38, size: 20.sp),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold))),
                      Text(time, style: TextStyle(color: Colors.white38, fontSize: 10.sp)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: TextStyle(color: Colors.white38, fontSize: 13.sp)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(dynamic order) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(image: NetworkImage(order.image), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id, style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                    Text(order.title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const Divider(color: Colors.white10),
          SizedBox(height: 20.h),
          _summaryRow("Item", "\$115.00"),
          _summaryRow("Shipping", "\$15.00"),
          _summaryRow("Taxes", "\$0.00"),
          _summaryRow("Processing Fee", "\$0.00"),
          _summaryRow("Buyer Contribution", "\$0.05", isHighlight: true),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL PAID", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
              Text("\$130.05", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 24.sp, fontWeight: FontWeight.w900)),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            "No platform markup added... \$0.05 contribution supports Better Futures Foundation.",
            style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isHighlight ? const Color(0xFFFF8BFF) : Colors.white38, fontSize: 14.sp)),
          Text(value, style: TextStyle(color: isHighlight ? const Color(0xFFFF8BFF) : Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
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
        child: Text(text, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
