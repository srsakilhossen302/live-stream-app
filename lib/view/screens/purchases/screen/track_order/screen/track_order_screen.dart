import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../global/widgets/custom_background.dart';
import '../../../../../../global/widgets/custom_bottom_navbar.dart';
import '../../../../../../data/services/api_url.dart';
import '../controller/track_order_controller.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrackOrderController());

    return CustomBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
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
                      Obx(() => Text(
                        "Order ${controller.displayOrderId}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      )),
                    ],
                  ),
                ),
                
                const Divider(color: Colors.white10, thickness: 1),
                
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF8B9BFF)));
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 120.h),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24.h),
                          // Map Section
                          _buildMapSection(controller),
                          
                          SizedBox(height: 32.h),
                          
                          // Status Card
                          _buildStatusCard(controller),
                          
                          SizedBox(height: 32.h),
                          
                          // Journey Updates
                          Text("JOURNEY UPDATES", style: TextStyle(color: Colors.white54, fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                          SizedBox(height: 24.h),
                          _buildJourneyTimeline(controller),
                          
                          SizedBox(height: 32.h),
                          
                          // Order Summary Card
                          _buildOrderSummaryCard(controller),
                          
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

  Widget _buildMapSection(TrackOrderController controller) {
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
                      Icon(Icons.circle, color: const Color(0xFF97A9FF), size: 6.sp),
                      SizedBox(width: 8.w),
                      Text("LIVE VIEW", style: TextStyle(color: const Color(0xFF97A9FF), fontSize: 10.sp, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Jersey City Distribution\nCenter",
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

  Widget _buildStatusCard(TrackOrderController controller) {
    final rawStatus = controller.deliveryStatus;
    final statusText = rawStatus.replaceAll('_', ' ').capitalizeFirst ?? rawStatus;

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
                    statusText,
                    style: TextStyle(color: const Color(0xFFAC8AFF), fontSize: 24.sp, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("EST. DELIVERY", style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                  Text(controller.estimatedDelivery, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          SizedBox(height: 28.h),
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

  Widget _buildJourneyTimeline(TrackOrderController controller) {
    final updates = controller.journeyUpdates;
    return Column(
      children: List.generate(updates.length, (index) {
        final item = updates[index];
        final title = item['status']?.toString() ?? item['title']?.toString() ?? 'Update';
        final description = item['description']?.toString() ?? item['text']?.toString() ?? '';
        final time = item['timestamp']?.toString() ?? item['time']?.toString() ?? '';
        final isFirst = index == 0;
        final isLast = index == updates.length - 1;

        IconData icon = Icons.local_shipping_rounded;
        if (title.toLowerCase().contains('shipped')) {
          icon = Icons.inventory_2_rounded;
        } else if (title.toLowerCase().contains('confirm') || title.toLowerCase().contains('order')) {
          icon = Icons.check_circle_outline_rounded;
        }

        return _timelineItem(
          icon: icon,
          title: title,
          subtitle: description,
          time: time,
          isActive: isFirst,
          isFirst: isFirst,
          isLast: isLast,
        );
      }),
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

  Widget _buildOrderSummaryCard(TrackOrderController controller) {
    final rawImg = controller.productImage;
    final String imgUrl = (rawImg.isNotEmpty && !rawImg.startsWith('http') && !rawImg.startsWith('data:image/'))
        ? "${ApiUrl.imageBaseUrl}${rawImg.startsWith('/') ? rawImg : '/$rawImg'}"
        : rawImg;

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
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(16.r),
                  image: imgUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)
                      : null,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10.r),
                  ],
                ),
                child: imgUrl.isEmpty
                    ? const Center(child: Icon(Icons.image, color: Colors.white24))
                    : null,
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.displayOrderId, style: TextStyle(color: const Color(0xFFAC8AFF), fontSize: 11.sp, fontWeight: FontWeight.w800)),
                    Text(controller.productTitle, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          const Divider(color: Colors.white10, thickness: 1),
          SizedBox(height: 24.h),
          _summaryRow("Item", "\$${controller.itemSubtotal.toStringAsFixed(2)}"),
          _summaryRow("Shipping", "\$${controller.shipping.toStringAsFixed(2)}"),
          _summaryRow("Taxes", "\$${controller.taxes.toStringAsFixed(2)}"),
          _summaryRow("Processing Fee", "\$${controller.processingFee.toStringAsFixed(2)}"),
          _summaryRow("Buyer Contribution", "\$${controller.charityContribution.toStringAsFixed(2)}", isHighlight: true),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL PAID", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
              Text("\$${controller.totalPaid.toStringAsFixed(2)}", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 26.sp, fontWeight: FontWeight.w900)),
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
