import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/bidshwap_controller.dart';
import '../model/my_trade_model.dart';
import '../model/trade_model.dart';

class BidShwapScreen extends GetView<BidShwapController> {
  const BidShwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BidShwapController());
    return CustomBackground(
      child: SafeArea(
        child: Obx(() {
          final isMyTrades = controller.selectedTopTab.value == 1;
          return Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => isMyTrades ? controller.changeTopTab(0) : Get.back(),
                      child: Icon(isMyTrades ? Icons.close : Icons.circle_notifications_outlined, // Placeholder for avatar
                        color: Colors.white, size: 24.sp),
                    ),
                    if (!isMyTrades) CircleAvatar(
                      radius: 20.r,
                      backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop"),
                    ),
                    Text(
                      isMyTrades ? "My Trades" : "Auction Live",
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
                      
                      // Top Tabs
                      _buildTopTabs(),
                      
                      if (!isMyTrades) ...[
                        SizedBox(height: 32.h),
                        _buildSearchBar(),
                        SizedBox(height: 32.h),
                        _buildFilters(),
                        SizedBox(height: 32.h),
                        Obx(() => Column(
                          children: controller.trades.map((trade) => _buildTradeCard(trade)).toList(),
                        )),
                      ] else ...[
                        SizedBox(height: 32.h),
                        _buildMyTradeFilters(),
                        SizedBox(height: 32.h),
                        Obx(() => Column(
                          children: controller.myTrades.map((trade) => _buildMyTradeCard(trade)).toList(),
                        )),
                      ],
                      
                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: List.generate(controller.topTabs.length, (index) {
          return Expanded(
            child: Obx(() {
              final isSelected = controller.selectedTopTab.value == index;
              return GestureDetector(
                onTap: () => controller.changeTopTab(index),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF282C36) : Colors.transparent,
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  child: Text(
                    controller.topTabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Color(0xff97A9FF),
                      fontSize: 13.sp,
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

  Widget _buildSearchBar() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white, size: 24.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: "Search deals & more",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 16.sp),
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.tune_rounded, color: Colors.white, size: 22.sp),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.filters.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == index;
            return GestureDetector(
              onTap: () => controller.changeFilter(index),
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Text(
                  controller.filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white38,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildTradeCard(TradeModel trade) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(36.r),
      ),
      child: Column(
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundImage: NetworkImage(trade.userAvatar),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trade.userName, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                    Row(
                      children: [
                        Icon(Icons.star, color: const Color(0xFFFF8BFF), size: 12.sp),
                        SizedBox(width: 4.w),
                        Text("${trade.userRating} (${trade.tradesCount})", style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text("VERIFIED AVAILABLE", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 9.sp, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          
          SizedBox(height: 28.h),
          
          // Offered Item & Looking For Section
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  Container(
                    height: 260.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      image: DecorationImage(
                        image: NetworkImage(trade.offeredItemImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 16.w,
                          bottom: 16.h,
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("OFFERED ITEM", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                SizedBox(height: 4.h),
                                Text(trade.offeredItemName, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900)),
                                Text(trade.offeredItemValue, style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                   SizedBox(height: 10.h),
                  
                  // Swap Icon sitting in the middle
                  Transform.translate(
                    offset: Offset(0, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(height: 10.h), // Tighten the gap
                        Positioned(
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B9BFF), // Added the missing background color
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B9BFF).withOpacity(0.4),
                                  blurRadius: 30.r,
                                  spreadRadius: 4.r,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.r), // Adjust padding to scale SVG
                                child: SvgPicture.asset(
                                  "assets/icons/Container.svg",
                                  fit: BoxFit.contain,
                                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn), // Ensure arrows are black
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),


                  // Looking For
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0B1E),
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("LOOKING FOR", style: TextStyle(color: const Color(0xFFFF8BFF), fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              SizedBox(height: 12.h),
                              Text(trade.lookingForItemName, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                              SizedBox(height: 4.h),
                              Text(trade.lookingForItemValue, style: TextStyle(color: Colors.white38, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        Icon(Icons.watch_outlined, color: Colors.white10, size: 28.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 32.h),
          
          // Action Buttons
          Row(
            children: [
              Expanded(child: _buildActionButton("View Details", Colors.white.withOpacity(0.06), Colors.white)),
              SizedBox(width: 16.w),
              Expanded(child: _buildActionButton("Make Offer", const Color(0xFF8B9BFF), Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyTradeFilters() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Row(
        children: List.generate(controller.myTradeFilters.length, (index) {
          return Expanded(
            child: Obx(() {
              final isSelected = controller.selectedMyTradeFilter.value == index;
              return GestureDetector(
                onTap: () => controller.changeMyTradeFilter(index),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF282C36) : Colors.transparent,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(
                    controller.myTradeFilters[index],
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
    Color statusTextColor = Colors.white;
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
                child: Text(statusText, style: TextStyle(color: statusTextColor, fontSize: 10.sp, fontWeight: FontWeight.w900)),
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
