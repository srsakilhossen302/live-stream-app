import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../data/services/api_url.dart';
import '../controller/agora_live_controller.dart';
import 'dart:convert';

class ViewerLiveScreen extends StatefulWidget {
  final Map<String, dynamic> streamData;
  const ViewerLiveScreen({super.key, required this.streamData});

  @override
  State<ViewerLiveScreen> createState() => _ViewerLiveScreenState();
}

class _ViewerLiveScreenState extends State<ViewerLiveScreen> {
  late AgoraLiveController ctrl;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
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
                      ctrl.isLoading.value
                          ? const CircularProgressIndicator(color: Color(0xFF8B9BFF))
                          : Icon(Icons.live_tv_rounded, color: Colors.white24, size: 64.sp),
                      SizedBox(height: 16.h),
                      Text(
                        ctrl.isLoading.value ? "Connecting to stream..." : "Waiting for host...",
                        style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                      ),
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

            // ── Top Overlay (Close button, LIVE count, Host info)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Close button
                          GestureDetector(
                            onTap: () async {
                              await ctrl.endStream();
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                              child: Icon(Icons.close_rounded, color: Colors.white, size: 22.sp),
                            ),
                          ),
                          // LIVE pill
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.white10, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.wifi_tethering_rounded, color: Colors.white, size: 10.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "LIVE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Obx(() => Text(
                                  ctrl.remoteJoined.value ? "2" : "1",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildHostProfileCard(),
                    ],
                  ),
                ),
              ),
            ),

            // ── Floating Elements (Bottom Overlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row containing Comments/Product (left) & Right Panel (right)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildChat(),
                                SizedBox(height: 12.h),
                                Obx(() {
                                  if (!ctrl.auctionActive.value) return const SizedBox.shrink();
                                  return _buildProductCard();
                                }),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          _buildRightSideControls(),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Bottom Row bar (Input, Custom, Bid capsule)
                      _buildBottomBar(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostProfileCard() {
    final seller = widget.streamData['sellerId'] ?? {};
    final username = "@${seller['username'] ?? 'jrehsales'}";
    final rating = seller['rating']?.toString() ?? "4.9";
    
    final isFollowing = false.obs;

    String avatarUrl = "";
    final sellerImage = (seller['profile'] ?? seller['image'] ?? seller['profileImageUrl'])?.toString();
    if (sellerImage != null && sellerImage.isNotEmpty) {
      avatarUrl = (sellerImage.startsWith('http') || sellerImage.startsWith('data:image/'))
          ? sellerImage
          : "${ApiUrl.imageBaseUrl}${sellerImage.startsWith('/') ? sellerImage : '/$sellerImage'}";
    } else {
      avatarUrl = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200";
    }

    return GestureDetector(
      onTap: () {
        final String sellerId = seller['_id'] ?? seller['id'] ?? '';
        if (sellerId.isNotEmpty) {
          Get.toNamed('/trader_profile', arguments: {
            "id": sellerId,
            "name": seller['fullName'] ?? seller['username'] ?? 'User',
            "avatar": avatarUrl,
            "bio": seller['bio'] ?? seller['description'] ?? '',
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username,
                  style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: const Color(0xFFFF41FF), size: 10.sp),
                    SizedBox(width: 2.w),
                    Text(
                      rating,
                      style: TextStyle(color: Colors.white70, fontSize: 9.sp, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Obx(() => GestureDetector(
              onTap: () => isFollowing.toggle(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isFollowing.value ? Colors.white12 : const Color(0xFF9EACFF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  isFollowing.value ? "FOLLOWED" : "FOLLOW",
                  style: TextStyle(
                    color: isFollowing.value ? Colors.white : Colors.black,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildChat() {
    return Container(
      height: 200.h,
      alignment: Alignment.bottomLeft,
      child: Obx(() {
        _scrollToBottom();
        return ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: 8.h),
          itemCount: ctrl.chatMessages.length,
          itemBuilder: (context, index) {
            final m = ctrl.chatMessages[index];
            return Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildCommentBubble(m),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCommentBubble(Map<String, String> m) {
    final user = m['user'] ?? '';
    final msg = m['msg'] ?? '';
    final role = m['role'] ?? 'viewer';
    final isBid = m['isBid'] == 'true';

    if (isBid) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF8B9BFF).withOpacity(0.3), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gavel_rounded, color: const Color(0xFF8B9BFF), size: 14.sp),
            SizedBox(width: 6.w),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$user ",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: msg,
                    style: TextStyle(
                      color: const Color(0xFF8B9BFF),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isHost = role == 'host';
    if (isHost) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B9BFF).withOpacity(0.55),
              const Color(0xFFBD8BFF).withOpacity(0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFBD8BFF).withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBD8BFF).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    "HOST",
                    style: TextStyle(
                      color: const Color(0xFF8B9BFF),
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              msg,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            msg,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildProductCard() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58.r,
                height: 58.r,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Obx(() {
                  final img = ctrl.currentProductImage.value;
                  if (img.isEmpty) {
                    return Icon(Icons.image, color: Colors.white24, size: 22.sp);
                  }
                  if (img.startsWith('data:image/') && img.contains('base64,')) {
                    try {
                      final base64Content = img.split('base64,').last;
                      final bytes = base64Decode(base64Content);
                      return Image.memory(bytes, fit: BoxFit.cover);
                    } catch (_) {
                      return Icon(Icons.image, color: Colors.white24, size: 22.sp);
                    }
                  }
                  return Image.network(
                    img.startsWith('http') ? img : "${ApiUrl.imageBaseUrl}$img",
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.white24, size: 22.sp),
                  );
                }),
              ),
              Positioned(
                top: -6.h,
                left: -6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF52C5),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    "HOT",
                    style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => Text(
                  ctrl.currentProductTitle.value.isEmpty ? "Live Product" : ctrl.currentProductTitle.value,
                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _buildBadgeTag("FREE SHIPPING"),
                    SizedBox(width: 4.w),
                    _buildBadgeTag("TAXES"),
                  ],
                ),
                SizedBox(height: 6.h),
                Obx(() => RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "\$ ",
                        style: TextStyle(
                          color: const Color(0xFF8B9BFF),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ctrl.currentBidPrice.value.toStringAsFixed(0),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white70, fontSize: 8.sp, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildRightSideControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          final count = ctrl.likeCount.value;
          final label = count >= 1000
              ? '${(count / 1000).toStringAsFixed(1)}K'
              : '$count';
          return GestureDetector(
            onTap: () => ctrl.sendLike(),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: const Color(0xFFFF528E),
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => Get.snackbar("Notification", "Notifications enabled for this live stream", snackPosition: SnackPosition.BOTTOM),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => Get.snackbar("Share", "Link copied to clipboard!", snackPosition: SnackPosition.BOTTOM),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.share_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
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
                      ctrl.sendChatMessage(val, role: 'viewer');
                      _chatController.clear();
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ctrl.sendChatMessage(_chatController.text, role: 'viewer');
                    _chatController.clear();
                  },
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () {
            _showBidSheet();
          },
          child: Container(
            height: 48.r,
            width: 48.r,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: Center(
              child: Text(
                "Custom",
                style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Obx(() {
          final nextBid = ctrl.currentBidPrice.value + 1;
          return GestureDetector(
            onTap: () => ctrl.placeBid(nextBid),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B9BFF), Color(0xFFBD8BFF)]),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "BID",
                        style: TextStyle(color: Colors.black45, fontSize: 8.sp, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        "\$${nextBid.toStringAsFixed(0)}",
                        style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 16.sp),
                ],
              ),
            ),
          );
        }),
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
