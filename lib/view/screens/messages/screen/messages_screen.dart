import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/messages_controller.dart';

class MessagesScreen extends GetView<MessagesController> {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MessagesController());
    return CustomBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                      ),
                      Text(
                        "Messages",
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),
                        
                        // Search Bar
                        _buildSearchBar(),
                        
                        SizedBox(height: 32.h),
                        
                        // Filters
                        _buildFilters(),
                        
                        SizedBox(height: 32.h),
                        
                        // Updates Section
                        _buildSectionHeader("UPDATES", badge: "2 NEW"),
                        SizedBox(height: 16.h),
                        _buildUpdateCard(
                          name: "@CardMaster",
                          message: "Your order has been shipped",
                          time: "14:22",
                          hasNew: true,
                          avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop",
                          tags: ["#ORD-24891", "Shipped 🚚"],
                        ),
                        _buildUpdateCard(
                          name: "@LuxeVault",
                          message: "Trade request accepted",
                          time: "Yesterday",
                          avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop",
                          tags: ["TRADE", "Completed 🤝"],
                        ),
                        
                        SizedBox(height: 32.h),
                        
                        // Messages Section
                        _buildSectionHeader("MESSAGES"),
                        SizedBox(height: 16.h),
                        _buildMessageRow(
                          name: "@Retro_Rick",
                          message: "can do \$450 if we close tonight. Let me know.",
                          time: "Oct 24",
                          avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1974&auto=format&fit=crop",
                        ),
                        _buildMessageRow(
                          name: "@AuctionQueen",
                          message: "Congratulations! You won the Crimson Blade auction.",
                          time: "Oct 20",
                          isSpecial: true,
                          avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop",
                        ),
                        _buildMessageRow(
                          name: "@Silent_Bidder",
                          message: "Thanks for the smooth transaction. Left 5 stars.",
                          time: "Oct 15",
                          avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1974&auto=format&fit=crop",
                        ),
                        
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating Action Button
            Positioned(
              bottom: 30.h,
              right: 16.w,
              left: 16.w,
              child: Center(
                child: Container(
                  height: 60.h,
                  width: 60.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B9BFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF8B9BFF).withOpacity(0.4), blurRadius: 20.r, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Icon(Icons.add, color: Colors.black, size: 32.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white12, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: "Search conversations, orders, or trades...",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 16.sp),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: List.generate(controller.filters.length, (index) {
        return Expanded(
          child: Obx(() {
            final isSelected = controller.selectedFilter.value == index;
            return GestureDetector(
              onTap: () => controller.changeFilter(index),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B9BFF) : const Color(0xFF161622),
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Text(
                  controller.filters[index],
                  textAlign: Alignment.center.x == 0 ? TextAlign.center : null,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white38,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, {String? badge}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
        if (badge != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(8.r)),
            child: Text(badge, style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.w900)),
          ),
      ],
    );
  }

  Widget _buildUpdateCard({required String name, required String message, required String time, required String avatar, List<String> tags = const [], bool hasNew = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 24.r, backgroundImage: NetworkImage(avatar)),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                        Row(
                          children: [
                            Text(time, style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w700)),
                            if (hasNew) ...[
                              SizedBox(width: 8.w),
                              Container(width: 8.h, height: 8.h, decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle)),
                            ],
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(message, style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(width: 64.w),
              ...tags.map((tag) => Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10.r)),
                child: Text(tag, style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w800)),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRow({required String name, required String message, required String time, required String avatar, bool isSpecial = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 28.r, backgroundImage: NetworkImage(avatar)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                    Text(time, style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSpecial ? const Color(0xFF8B9BFF) : Colors.white70,
                    fontSize: 14.sp,
                    fontWeight: isSpecial ? FontWeight.w900 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
