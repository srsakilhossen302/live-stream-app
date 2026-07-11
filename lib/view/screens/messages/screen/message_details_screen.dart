import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/app_route.dart';
import '../../../../global/widgets/custom_background.dart';
import '../../purchases/model/purchase_model.dart';
import '../controller/message_details_controller.dart';
import '../../../../data/services/api_url.dart';

class MessageDetailsScreen extends GetView<MessageDetailsController> {
  const MessageDetailsScreen({super.key});

  PurchaseModel _getMockOrder() {
    return PurchaseModel(
      id: "ORD-24891",
      title: "Vintage Pokémon Card Pack",
      curator: "CardMaster",
      date: "Oct 21, 2023",
      price: "\$1,250",
      carrier: "USPS",
      image: "",
      trackingId: "9400 1112 3456 7890 1234 56",
      status: OrderStatus.inTransit,
      estimatedDelivery: "October 24",
      itemPrice: 1250,
      shippingPrice: 15.50,
      taxes: 42.00,
      processingFee: 12.00,
      buyerContribution: 0,
      totalPaid: 1319.50,
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(MessageDetailsController());
    return CustomBackground(
      safeAreaBottom: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Pinned Item — only when chat has an associated order
            Obx(() => controller.hasOrder.value
                ? _buildPinnedItem()
                : const SizedBox.shrink()),
            
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF8B9BFF),
                backgroundColor: const Color(0xFF161622),
                onRefresh: () => controller.fetchMessages(),
                child: Obx(() {
                  // Loading shimmer
                  if (controller.isLoading.value) {
                    return ListView(
                      padding: EdgeInsets.all(16.r),
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBubbleShimmer(isMe: false),
                        _buildBubbleShimmer(isMe: true),
                        _buildBubbleShimmer(isMe: false),
                        _buildBubbleShimmer(isMe: true),
                      ],
                    );
                  }

                  // Empty state
                  if (controller.messages.isEmpty) {
                    return ListView(
                      controller: controller.scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(24.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E2C),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.forum_outlined, color: const Color(0xFF8B9BFF), size: 40.sp),
                              ),
                              SizedBox(height: 20.h),
                              Text("No messages yet", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                              SizedBox(height: 8.h),
                              Text("Say hello to start the conversation!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Message list — oldest at top, newest at BOTTOM
                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index];

                      // Date separator
                      if (msg['isDate'] == true) {
                        return _buildDateSeparator(msg['message'] ?? '');
                      }

                      // Order shipped card — special message type
                      if (msg['isOrderCard'] == true) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 8.h),
                            _buildTrackingCard(),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionChip(
                                    Icons.location_on_outlined,
                                    "TRACK ORDER",
                                    onTap: () => Get.toNamed(
                                      AppRoute.trackOrder,
                                      arguments: _getMockOrder(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildActionChip(
                                    Icons.check_circle_outline,
                                    "CONFIRM DELIVERY",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      }

                      final bool isMe = msg['isMe'] == true;
                      final bool isRead = msg['isRead'] == true;

                      return _buildMessageBubble(
                        message: msg['message'] ?? '',
                        time: msg['time'] ?? 'Now',
                        isMe: isMe,
                        isRead: isRead,
                      );
                    },
                  );
                }),
              ),
            ),

            // Input Bar
            _buildInputBar(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final avatar = controller.partnerAvatar.value;
        final name = controller.partnerName.value;
        final avatarUrl = (avatar.isNotEmpty && !avatar.startsWith('http') && !avatar.startsWith('data:image/'))
            ? "${ApiUrl.imageBaseUrl}${avatar.startsWith('/') ? avatar : '/$avatar'}"
            : avatar.isNotEmpty ? avatar : "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop";

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final String pid = controller.partnerId.value;
            if (pid.isNotEmpty) {
              Get.toNamed(AppRoute.traderProfile, arguments: {
                "id": pid,
                "name": name,
                "avatar": avatarUrl,
              });
            }
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8BFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                  Text("ACTIVE NOW", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPinnedItem() {
    final order = controller.orderData;
    final String title = order['title'] ?? (order['productId'] is Map ? order['productId']['title'] : null) ?? "Vintage Pokémon Card Pack";
    final String orderId = order['id'] ?? order['_id'] ?? "ORD-24891";
    
    // Extract image path
    String imgPath = "";
    final List? prodImages = (order['productId'] is Map) ? (order['productId']['images'] as List?) : null;
    if (prodImages != null && prodImages.isNotEmpty) {
      imgPath = prodImages[0].toString();
    } else {
      imgPath = order['image'] ?? (order['productId'] is Map ? order['productId']['image'] : null) ?? "";
    }
    
    final String imgUrl = (imgPath.isNotEmpty)
        ? (imgPath.startsWith('http') ? imgPath : "${ApiUrl.imageBaseUrl}${imgPath.startsWith('/') ? imgPath : '/$imgPath'}")
        : "";

    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10.r),
              image: imgUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imgUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imgUrl.isEmpty
                ? const Center(child: Icon(Icons.image, color: Colors.white24))
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ORDER #$orderId", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                SizedBox(height: 2.h),
                Text(title, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(color: const Color(0xFF161622), borderRadius: BorderRadius.circular(16.r)),
          child: Text(label, style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({required String message, required String time, required bool isMe, bool isRead = false}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 0.75.sw),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF8B9BFF) : const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
                bottomLeft: Radius.circular(isMe ? 24.r : 4.r),
                bottomRight: Radius.circular(isMe ? 4.r : 24.r),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(color: isMe ? Colors.black : Colors.white70, fontSize: 14.sp, height: 1.5, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                if (isMe && isRead) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.done_all_rounded, color: const Color(0xFF8B9BFF), size: 14.sp),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("ORDER SHIPPED 🚚", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8.r)),
                    child: Text("IN TRANSIT", style: TextStyle(color: Colors.white38, fontSize: 9.sp, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              Icon(Icons.local_shipping_outlined, color: Colors.white24, size: 24.sp),
            ],
          ),
          SizedBox(height: 4.h),
          Text("Your order is on the way!", style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.w700)),
          
          SizedBox(height: 40.h),
          
          // Map Placeholder / Timeline
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 250.w,
                  height: 2.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white10, const Color(0xFF8B9BFF).withOpacity(0.5), Colors.white10],
                    ),
                  ),
                ),
                Positioned(
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(color: Color(0xFF161622), shape: BoxShape.circle),
                    child: Icon(Icons.location_on, color: const Color(0xFF8B9BFF), size: 28.sp),
                  ),
                ),
                Positioned(
                  top: -40.h,
                  right: -20.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(color: const Color(0xFFFF8BFF).withOpacity(0.2), borderRadius: BorderRadius.circular(10.r)),
                    child: Text("ETA: 2 Days", style: TextStyle(color: const Color(0xFFFF8BFF), fontSize: 10.sp, fontWeight: FontWeight.w900)),
                  ),
                ),
                Positioned(
                  bottom: -30.h,
                  child: Column(
                    children: [
                      Text("📍 Current Location", style: TextStyle(color: Colors.white38, fontSize: 9.sp, fontWeight: FontWeight.w900)),
                      Text("Moving towards destination", style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 60.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrackingInfo("CARRIER", "USPS"),
              _buildTrackingInfo("ESTIMATED DELIVERY", "October 24", isAccent: true),
            ],
          ),
          SizedBox(height: 20.h),
          _buildTrackingInfo("TRACKING NUMBER", "9400 1112 3456 7890 1234 56", isCopyable: true),
          
          SizedBox(height: 24.h),
          
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(16.r)),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.white38, size: 18.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("LAST UPDATE", style: TextStyle(color: Colors.white38, fontSize: 9.sp, fontWeight: FontWeight.w900)),
                      Text("Departed USPS Facility Chicago, IL — Oct 21, 8:14 AM", style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(AppRoute.trackOrder, arguments: _getMockOrder()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B9BFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                elevation: 0,
              ),
              child: Text("TRACK ORDER", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo(String label, String value, {bool isAccent = false, bool isCopyable = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        SizedBox(height: 4.h),
        Row(
          children: [
            Text(value, style: TextStyle(color: isAccent ? const Color(0xFFFF8BFF) : Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900)),
            if (isCopyable) ...[
              SizedBox(width: 8.w),
              Icon(Icons.copy, color: Colors.white24, size: 16.sp),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBubbleShimmer({required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        width: 200.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
            bottomLeft: Radius.circular(isMe ? 24.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 24.r),
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF161622),
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF8B9BFF), size: 18.sp),
            SizedBox(width: 8.w),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, (bottomPadding > 0 ? bottomPadding : 16.h) + 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D15),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.add, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF161622),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.chatInputController,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 14.sp),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        controller.sendMessage(val);
                      },
                    ),
                  ),
                  Icon(Icons.sentiment_satisfied_alt_outlined, color: Colors.white24, size: 24.sp),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: () {
              controller.sendMessage(controller.chatInputController.text);
            },
            child: Container(
              height: 56.h,
              width: 56.h,
              decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle),
              child: Icon(Icons.send_rounded, color: Colors.black, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }
}
