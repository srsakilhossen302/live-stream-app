import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                      children: controller.myTrades.map((trade) => _buildMyTradeCard(trade)).toList(),
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
    Color statusColor;
    String statusText;
    switch (trade.status) {
      case MyTradeStatus.shipped:
        statusColor = const Color(0xFF2E1E5D);
        statusText = "SHIPPED";
        break;
      case MyTradeStatus.pending:
        statusColor = const Color(0xFF282C36);
        statusText = "PENDING";
        break;
      case MyTradeStatus.completed:
        statusColor = const Color(0xFF5D1E4E);
        statusText = "COMPLETED";
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TRADE ID: ${trade.tradeId}", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(statusText, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(trade.title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900, height: 1.2)),
          SizedBox(height: 24.h),
          
          if (trade.status == MyTradeStatus.completed) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TRADER", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        CircleAvatar(radius: 14.r, backgroundImage: NetworkImage(trade.traderAvatar ?? "")),
                        SizedBox(width: 10.w),
                        Text(trade.traderName, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("DATE", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    SizedBox(height: 10.h),
                    Text(trade.date ?? "", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildActionButton("View Receipt", const Color(0xFF8B9BFF), Colors.black),
            SizedBox(height: 24.h),
            Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTradeItemImage(trade.item1Image),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Icon(Icons.sync_alt_rounded, color: const Color(0xFF8B9BFF), size: 24.sp),
                  ),
                  _buildTradeItemImage(trade.item2Image),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildTradeItemImage(trade.item1Image, small: true),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Icon(Icons.sync_alt_rounded, color: Colors.white10, size: 20.sp),
                      ),
                      _buildTradeItemImage(trade.item2Image, small: true),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Trader", style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.w800)),
                    Text(trade.traderName, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(child: _buildActionButton("View Trade", const Color(0xFF1E1E2C), Colors.white)),
                SizedBox(width: 16.w),
                Container(
                  height: 56.h,
                  width: 56.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(Icons.chat_bubble_outline_rounded, color: const Color(0xFF8B9BFF), size: 22.sp),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTradeItemImage(String url, {bool small = false}) {
    return Container(
      width: small ? 64.w : 120.w,
      height: small ? 64.w : 120.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(small ? 14.r : 24.r),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildActionButton(String text, Color bg, Color textCol) {
    return SizedBox(
      height: 56.h,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textCol,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
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
