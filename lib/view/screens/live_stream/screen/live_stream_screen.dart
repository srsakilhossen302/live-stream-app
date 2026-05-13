import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../home/controller/home_controller.dart';
import '../controller/live_stream_controller.dart';

class LiveStreamScreen extends GetView<LiveStreamController> {
  const LiveStreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LiveStreamController());
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical Video Feed (TikTok style)
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: controller.videoUrls.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              return Obx(() {
                if (controller.controllers.length > index) {
                  final vController = controller.controllers[index];
                  return vController.value.isInitialized
                      ? SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: vController.value.size.width,
                              height: vController.value.size.height,
                              child: VideoPlayer(vController),
                            ),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator(color: Color(0xFF8B9BFF)));
                }
                return const Center(child: CircularProgressIndicator(color: Color(0xFF8B9BFF)));
              });
            },
          ),

          // Overlay UI
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildOverlayUI() {
    final LiveItemModel? item = Get.arguments;
    return SafeArea(
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                    child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(20.r)),
                  child: Row(
                    children: [
                      Icon(Icons.sensors, color: Colors.red, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w900)),
                      SizedBox(width: 8.w),
                      Container(width: 1, height: 12.h, color: Colors.white24),
                      SizedBox(width: 8.w),
                      Text(item?.viewers ?? "64", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: NetworkImage(item?.image ?? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop"),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item?.curator ?? "@jrehsales", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                    Row(
                      children: [
                        Icon(Icons.star, color: const Color(0xFFFF8BFF), size: 12.sp),
                        SizedBox(width: 4.w),
                        Text("4.9", style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(color: const Color(0xFF8B9BFF), borderRadius: BorderRadius.circular(20.r)),
                  child: Text("FOLLOW", style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Section
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left Column: Chat & Product
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chat Bubbles
                      _buildChatBubble("@user123", "Is there a warranty on this?"),
                      _buildChatBubble("@short023", "The zoom is incredible!"),
                      _buildChatBubble("@short028", "Just placed my bid 🚀"),
                      
                      SizedBox(height: 16.h),

                      // Product Card
                      _buildProductCard(),
                      
                      SizedBox(height: 16.h),

                      // Input bar
                      _buildInputBar(),
                    ],
                  ),
                ),
                
                SizedBox(width: 16.w),

                // Right Column: Actions
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(Icons.favorite, "1.2K", color: const Color(0xFFFF8BFF)),
                    _buildActionButton(Icons.notifications, ""),
                    _buildActionButton(Icons.share, ""),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String user, String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user, style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w900)),
          Text(message, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622).withOpacity(0.8),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1613771404721-1f92d799e49f?q=80&w=1000&auto=format&fit=crop"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(color: const Color(0xFFFF8BFF), borderRadius: BorderRadius.circular(4.r)),
                  child: Text("HOT", style: TextStyle(color: Colors.black, fontSize: 7.sp, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ear Wax OtoScope", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _buildBadge("FREE SHIPPING"),
                    SizedBox(width: 4.w),
                    _buildBadge("TAXES"),
                  ],
                ),
                SizedBox(height: 4.h),
                Text("\$1", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4.r)),
      child: Text(label, style: TextStyle(color: Colors.white38, fontSize: 8.sp, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildInputBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(24.r)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    decoration: InputDecoration(
                      hintText: "Say something...",
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 12.sp),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(Icons.send_rounded, color: Colors.white38, size: 20.sp),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24.r), border: Border.all(color: Colors.white12)),
          child: Center(child: Text("Custom", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w900))),
        ),
        SizedBox(width: 8.w),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(color: const Color(0xFF8B9BFF), borderRadius: BorderRadius.circular(24.r)),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("BID", style: TextStyle(color: Colors.black54, fontSize: 8.sp, fontWeight: FontWeight.w900)),
                  Text("\$1", style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                ],
              ),
              SizedBox(width: 8.w),
              Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, {Color color = Colors.white}) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.w900)),
          ),
      ],
    );
  }
}
