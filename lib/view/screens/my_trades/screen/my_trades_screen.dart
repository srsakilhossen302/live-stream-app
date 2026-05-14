import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/my_trades_controller.dart';
import '../model/my_trade_model.dart';

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
                  Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26.sp),
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
                    Obx(() => Column(
                      children: controller.filteredTrades.map((trade) => _buildMyTradeCard(trade)).toList(),
                    )),
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
                            backgroundImage: NetworkImage(trade.traderAvatar ?? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100"),
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
            _buildActionButton("View Receipt", const Color(0xFF8B9BFF), Colors.black, fullWidth: true),
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
            Row(
              children: [
                Expanded(child: _buildActionButton("View Trade", const Color(0xFF1E1E2C), Colors.white, onTap: () => Get.toNamed('/trade_details'))),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () => Get.toNamed('/message_details'),
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
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(small ? 16.r : 24.r),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
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
}
