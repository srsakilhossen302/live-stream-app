import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../data/services/api_url.dart';
import '../controller/agora_live_controller.dart';

class ViewerLiveScreen extends StatefulWidget {
  final Map<String, dynamic> streamData;
  const ViewerLiveScreen({super.key, required this.streamData});

  @override
  State<ViewerLiveScreen> createState() => _ViewerLiveScreenState();
}

class _ViewerLiveScreenState extends State<ViewerLiveScreen> {
  late AgoraLiveController ctrl;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(AgoraLiveController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.joinAsViewer(widget.streamData);
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await ctrl.endStream();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Remote Video (Host's camera)
            Obx(() {
              if (ctrl.engine != null && ctrl.remoteJoined.value && ctrl.remoteUid.value != -1) {
                return AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: ctrl.engine!,
                    canvas: VideoCanvas(uid: ctrl.remoteUid.value),
                    connection: RtcConnection(channelId: ctrl.channelName.value),
                    useFlutterTexture: false,
                    useAndroidSurfaceView: true,
                  ),
                );
              }
              return Container(
                color: const Color(0xFF0A0A14),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => ctrl.isLoading.value
                          ? const CircularProgressIndicator(color: Color(0xFF8B9BFF))
                          : Icon(Icons.live_tv_rounded, color: Colors.white24, size: 64.sp)),
                      SizedBox(height: 16.h),
                      Obx(() => Text(
                        ctrl.isLoading.value ? "Connecting to stream..." : "Waiting for host...",
                        style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                      )),
                    ],
                  ),
                ),
              );
            }),

            // ── Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    stops: const [0.0, 0.2, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // ── Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await ctrl.endStream();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // LIVE badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16.r)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6.r, height: 6.r, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            SizedBox(width: 5.w),
                            Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Obx(() => Text(
                          ctrl.streamTitle.value,
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chat
                    _buildChat(),
                    SizedBox(height: 12.h),

                    // Auction Card
                    Obx(() {
                      if (!ctrl.auctionActive.value) return const SizedBox.shrink();
                      return Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            // Product Thumb
                            Container(
                              width: 54.r,
                              height: 54.r,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Obx(() {
                                final img = ctrl.currentProductImage.value;
                                return img.isNotEmpty
                                    ? Image.network(
                                        img.startsWith('http') ? img : "${ApiUrl.imageBaseUrl}$img",
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.white24, size: 22.sp),
                                      )
                                    : Icon(Icons.image, color: Colors.white24, size: 22.sp);
                              }),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                    ctrl.currentProductTitle.value.isEmpty ? "Live Auction" : ctrl.currentProductTitle.value,
                                    style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  SizedBox(height: 4.h),
                                  Obx(() => Text(
                                    "Current: \$${ctrl.currentBidPrice.value.toStringAsFixed(0)}",
                                    style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 13.sp, fontWeight: FontWeight.w800),
                                  )),
                                ],
                              ),
                            ),
                            // Bid Button
                            GestureDetector(
                              onTap: () => _showBidSheet(),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF8B9BFF), Color(0xFFBD8BFF)]),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text("BID", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 12.h),
                    // Chat Input
                    _buildChatInput(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChat() {
    return Obx(() {
      final msgs = ctrl.chatMessages.toList().reversed.take(4).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: msgs.map((m) => Padding(
          padding: EdgeInsets.only(bottom: 3.h),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "${m['user']}: ", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 12.sp, fontWeight: FontWeight.w800)),
                TextSpan(text: m['msg'], style: TextStyle(color: Colors.white, fontSize: 12.sp)),
              ],
            ),
          ),
        )).toList(),
      );
    });
  }

  Widget _buildChatInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: TextField(
              controller: _chatController,
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: "Say something...",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13.sp),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11.h),
              ),
              onSubmitted: (val) {
                ctrl.sendChatMessage(val);
                _chatController.clear();
              },
            ),
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: () {
            ctrl.sendChatMessage(_chatController.text);
            _chatController.clear();
          },
          child: Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle),
            child: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
          ),
        ),
      ],
    );
  }

  void _showBidSheet() {
    final bidAmountCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: const Color(0xFF11111A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            Text("Place Your Bid", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 8.h),
            Obx(() => Text(
              "Current highest: \$${ctrl.currentBidPrice.value.toStringAsFixed(0)}",
              style: TextStyle(color: Colors.white38, fontSize: 13.sp),
            )),
            SizedBox(height: 20.h),

            // Quick bid chips
            Obx(() {
              final base = ctrl.currentBidPrice.value;
              return Row(
                children: [base + 100, base + 250, base + 500].map((amt) {
                  return GestureDetector(
                    onTap: () {
                      bidAmountCtrl.text = amt.toStringAsFixed(0);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10.w),
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text("+\$${(amt - base).toStringAsFixed(0)}",
                          style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w800)),
                    ),
                  );
                }).toList(),
              );
            }),

            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161622),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: bidAmountCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  hintText: "Enter bid amount",
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 16.sp),
                  border: InputBorder.none,
                  prefixText: "\$",
                  prefixStyle: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 18.sp, fontWeight: FontWeight.w900),
                  contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () {
                final amount = double.tryParse(bidAmountCtrl.text);
                if (amount != null) ctrl.placeBid(amount);
              },
              child: Container(
                width: double.infinity,
                height: 56.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8B9BFF), Color(0xFFBD8BFF)]),
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Text("Confirm Bid", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
