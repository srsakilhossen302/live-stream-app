import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/bidshwap_controller.dart';
import '../model/trade_model.dart';

class BidShwapScreen extends GetView<BidShwapController> {
  const BidShwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BidShwapController());
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
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop"),
                  ),
                  Text(
                    "Auction Live",
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
                    
                    SizedBox(height: 32.h),
                    
                    // Search Bar
                    _buildSearchBar(),
                    
                    SizedBox(height: 32.h),
                    
                    // Filters
                    _buildFilters(),
                    
                    SizedBox(height: 32.h),
                    
                    // Trade List
                    Obx(() => Column(
                      children: controller.trades.map((trade) => _buildTradeCard(trade)).toList(),
                    )),
                    
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                    color: isSelected ? const Color(0xFF1E1E2C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  child: Text(
                    controller.topTabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white38,
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
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(trade.userAvatar),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trade.userName, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.pink, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text("${trade.userRating} (${trade.tradesCount})", style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text("VERIFIED AVAILABLE", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 9.sp, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          // Offered Item
          Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: 240.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      image: DecorationImage(
                        image: NetworkImage(trade.offeredItemImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                      padding: EdgeInsets.all(20.r),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("OFFERED ITEM", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          SizedBox(height: 4.h),
                          Text(trade.offeredItemName, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          Text(trade.offeredItemValue, style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Looking For
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0B1E),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("LOOKING FOR", style: TextStyle(color: Colors.pink, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              SizedBox(height: 8.h),
                              Text(trade.lookingForItemName, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                              Text(trade.lookingForItemValue, style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        Icon(Icons.watch_outlined, color: Colors.white24, size: 24.sp),
                      ],
                    ),
                  ),
                ],
              ),
              // Swap Button
              Positioned(
                top: 215.h,
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B9BFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF161622), width: 4.w),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10.r),
                    ],
                  ),
                  child: Icon(Icons.sync_alt_rounded, color: Colors.black, size: 24.sp),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          // Action Buttons
          Row(
            children: [
              Expanded(child: _buildActionButton("View Details", const Color(0xFF1E1E2C), Colors.white)),
              SizedBox(width: 16.w),
              Expanded(child: _buildActionButton("Make Offer", const Color(0xFF8B9BFF), Colors.black)),
            ],
          ),
        ],
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
        ),
        child: Text(text, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
