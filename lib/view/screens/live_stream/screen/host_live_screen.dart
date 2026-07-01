import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/agora_live_controller.dart';
import 'dart:convert';
import '../../../../data/services/api_url.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';

class HostLiveScreen extends StatefulWidget {
  const HostLiveScreen({super.key});

  @override
  State<HostLiveScreen> createState() => _HostLiveScreenState();
}

class _HostLiveScreenState extends State<HostLiveScreen> {
  final TextEditingController _chatController = TextEditingController();
  late AgoraLiveController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<AgoraLiveController>();
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
        _showEndStreamDialog(ctrl);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Local Camera Preview
            Obx(() {
              if (ctrl.engine != null && ctrl.isLocalVideoReady.value) {
                return AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: ctrl.engine!,
                    canvas: const VideoCanvas(
                      uid: 0,
                      renderMode: RenderModeType.renderModeFit,
                      mirrorMode: VideoMirrorModeType.videoMirrorModeAuto,
                    ),
                    useFlutterTexture: false,
                    useAndroidSurfaceView: true,
                  ),
                );
              }
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF8B9BFF)),
                      SizedBox(height: 16.h),
                      Text("Starting camera...",
                          style: TextStyle(color: Colors.white60, fontSize: 14.sp)),
                    ],
                  ),
                ),
              );
            }),

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
                      // LIVE badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 7.r, height: 7.r, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            SizedBox(width: 6.w),
                            Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Obx(() => Text(
                        ctrl.streamTitle.value,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      const Spacer(),
                      // End button
                      GestureDetector(
                        onTap: () => _showEndStreamDialog(ctrl),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text("End", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Right Side Controls
            Positioned(
              right: 16.w,
              bottom: 200.h,
              child: Obx(() => Column(
                children: [
                  _sideButton(
                    ctrl.isCameraOn.value ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    ctrl.isCameraOn.value ? Colors.white24 : Colors.red.withValues(alpha: 0.6),
                    onTap: ctrl.toggleCamera,
                  ),
                  SizedBox(height: 16.h),
                  _sideButton(
                    ctrl.isMicOn.value ? Icons.mic_rounded : Icons.mic_off_rounded,
                    ctrl.isMicOn.value ? Colors.white24 : Colors.red.withValues(alpha: 0.6),
                    onTap: ctrl.toggleMic,
                  ),
                  SizedBox(height: 16.h),
                  _sideButton(Icons.flip_camera_ios_rounded, Colors.white24, onTap: () {
                    ctrl.engine?.switchCamera();
                  }),
                ],
              )),
            ),

            // ── Auction Card (bottom)
            Obx(() {
              if (!ctrl.auctionActive.value) return const SizedBox.shrink();
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.95)],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Chat messages
                      _buildChat(ctrl),
                      SizedBox(height: 12.h),
                      // Auction Info Row
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            // Product thumb
                            Obx(() {
                              final img = ctrl.currentProductImage.value;
                              return Container(
                                width: 54.r,
                                height: 54.r,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: img.isNotEmpty
                                    ? Image.network(
                                        img.startsWith('http') ? img : "${ApiUrl.imageBaseUrl}$img",
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.white24, size: 22.sp),
                                      )
                                    : Icon(Icons.image, color: Colors.white24, size: 22.sp),
                              );
                            }),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                    ctrl.currentProductTitle.value.isEmpty ? "Auction Item" : ctrl.currentProductTitle.value,
                                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  SizedBox(height: 4.h),
                                  Obx(() => Text(
                                    "Current Bid: \$${ctrl.currentBidPrice.value.toStringAsFixed(0)}",
                                    style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 13.sp, fontWeight: FontWeight.w800),
                                  )),
                                ],
                              ),
                            ),
                            // HOST sees total viewers badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove_red_eye_outlined, color: Colors.white60, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Obx(() => Text(
                                    ctrl.remoteJoined.value ? "1" : "0",
                                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Chat input
                      _buildChatInput(ctrl),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _sideButton(IconData icon, Color bg, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }

  Widget _buildChat(AgoraLiveController ctrl) {
    return Obx(() {
      final msgs = ctrl.chatMessages.toList().reversed.take(4).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: msgs.map((m) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
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

  Widget _buildChatInput(AgoraLiveController ctrl) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: Colors.white10),
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

  void _showEndStreamDialog(AgoraLiveController ctrl) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stop_circle_outlined, color: Colors.red, size: 48.sp),
              SizedBox(height: 16.h),
              Text("End Stream?",
                  style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
              SizedBox(height: 8.h),
              Text("This will end your live stream for all viewers.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13.sp)),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        ctrl.endStream();
                      },
                      child: Container(
                        height: 48.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Text("End Stream", style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
