import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controller/live_stream_controller.dart';

class LiveStreamScreen extends StatelessWidget {
  const LiveStreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveStreamController());
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: controller.streams.length,
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          final stream = controller.streams[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background Video
              GetBuilder<LiveStreamController>(
                builder: (ctrl) {
                  if (ctrl.videoControllers.length > index &&
                      ctrl.videoReady.length > index &&
                      ctrl.videoReady[index]) {
                    final vc = ctrl.videoControllers[index];
                    return SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: vc.value.size.width,
                          height: vc.value.size.height,
                          child: VideoPlayer(vc),
                        ),
                      ),
                    );
                  }
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B9BFF),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),

              // Dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0, 0.2, 0.6, 1],
                  ),
                ),
              ),

              // Overlay UI
              _buildOverlayUI(stream),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverlayUI(LiveStreamModel stream) {
    return SafeArea(
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                        color: Colors.black26, shape: BoxShape.circle),
                    child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Row(
                    children: [
                      Icon(Icons.sensors, color: Colors.red, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text("LIVE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900)),
                      SizedBox(width: 8.w),
                      Container(
                          width: 1, height: 12.h, color: Colors.white24),
                      SizedBox(width: 8.w),
                      Text(stream.viewers,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Creator Info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundImage: NetworkImage(stream.productImage),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stream.curator,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900)),
                    Row(
                      children: [
                        Icon(Icons.star,
                            color: const Color(0xFFFF8BFF), size: 12.sp),
                        SizedBox(width: 4.w),
                        Text("4.9",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                      color: const Color(0xFF8B9BFF),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text("FOLLOW",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Section
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChatBubble("@user123", "Is there a warranty?"),
                      _buildChatBubble("@short023", "The zoom is incredible!"),
                      _buildChatBubble("@short028", "Just placed my bid 🚀"),
                      SizedBox(height: 12.h),
                      _buildProductCard(stream),
                      SizedBox(height: 12.h),
                      _buildInputBar(stream),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(Icons.favorite, "1.2K",
                        color: const Color(0xFFFF8BFF)),
                    _buildActionButton(Icons.notifications_none, ""),
                    _buildActionButton(Icons.share_outlined, ""),
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
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
          color: Colors.black45, borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user,
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900)),
          Text(message,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductCard(LiveStreamModel stream) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  stream.productImage,
                  width: 60.r,
                  height: 60.r,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 60.r, height: 60.r, color: Colors.white10),
                ),
              ),
              Positioned(
                top: 3,
                right: 3,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF8BFF),
                      borderRadius: BorderRadius.circular(4.r)),
                  child: Text("HOT",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stream.productTitle,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 4.h),
                Row(children: [
                  _buildBadge("FREE SHIPPING"),
                  SizedBox(width: 4.w),
                  _buildBadge("TAXES"),
                ]),
                SizedBox(height: 4.h),
                Text(stream.productPrice,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) => Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
            color: Colors.white10, borderRadius: BorderRadius.circular(4.r)),
        child: Text(label,
            style: TextStyle(
                color: Colors.white38,
                fontSize: 8.sp,
                fontWeight: FontWeight.w900)),
      );

  Widget _buildInputBar(LiveStreamModel stream) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(22.r)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    decoration: InputDecoration(
                      hintText: "Say something...",
                      hintStyle:
                          TextStyle(color: Colors.white38, fontSize: 12.sp),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Icon(Icons.send_rounded,
                    color: Colors.white38, size: 18.sp),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: Colors.white12)),
          child: Center(
              child: Text("Custom",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900))),
        ),
        SizedBox(width: 8.w),
        Container(
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
              color: const Color(0xFF8B9BFF),
              borderRadius: BorderRadius.circular(22.r)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("BID",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w900)),
                  Text(stream.productPrice,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              SizedBox(width: 6.w),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.black, size: 18.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label,
      {Color color = Colors.white}) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: label.isEmpty ? 16.h : 4.h),
          padding: EdgeInsets.all(11.r),
          decoration: const BoxDecoration(
              color: Colors.black26, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Text(label,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900)),
          ),
      ],
    );
  }
}
