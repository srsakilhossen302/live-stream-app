import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/app_route.dart';
import '../../../../global/widgets/custom_background.dart';
import '../../messages/controller/messages_controller.dart';
import '../controller/trader_profile_controller.dart';
import '../../../../data/services/api_url.dart';

class TraderProfileScreen extends GetView<TraderProfileController> {
  const TraderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TraderProfileController());
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          color: const Color(0xFF8B9BFF),
          backgroundColor: const Color(0xFF161622),
          onRefresh: () => controller.refreshAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.h),
                Obx(() => _buildProfileHeader()),
                SizedBox(height: 32.h),
                Obx(() => _buildStatsRow()),
                SizedBox(height: 32.h),
                Obx(() => _buildActionButtons()),
                SizedBox(height: 40.h),
                Obx(() => _buildTabs()),
                SizedBox(height: 24.h),
                Obx(() => _buildTabContent()),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── APP BAR ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
        onPressed: () => Get.back(),
      ),
      title: Obx(() => Text(
            controller.displayName,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900),
          )),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: Colors.white, size: 22.sp),
          onPressed: () {},
        ),
      ],
    );
  }

  // ─── PROFILE HEADER ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    if (controller.isLoading.value && controller.traderName.value.isEmpty) {
      return _buildHeaderShimmer();
    }
    if (controller.hasError.value && controller.traderName.value.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.white38, size: 48.sp),
            SizedBox(height: 12.h),
            Text(controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => controller.fetchTraderProfile(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                    color: const Color(0xFF8B9BFF),
                    borderRadius: BorderRadius.circular(20.r)),
                child: Text('Retry',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Avatar
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF8B9BFF).withOpacity(0.4), width: 3),
              ),
              child: CircleAvatar(
                radius: 60.r,
                backgroundColor: const Color(0xFF1E1E2C),
                backgroundImage: controller.displayAvatar.isNotEmpty
                    ? NetworkImage(controller.displayAvatar)
                    : null,
                child: controller.displayAvatar.isEmpty
                    ? Icon(Icons.person, color: Colors.white38, size: 48.sp)
                    : null,
              ),
            ),
            if (controller.isVerified.value)
              Positioned(
                bottom: 4,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                      color: Color(0xFF0F0B1E), shape: BoxShape.circle),
                  child: Icon(Icons.verified,
                      color: const Color(0xFF8B9BFF), size: 22.sp),
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),

        // Name
        Text(
          controller.displayName,
          style: TextStyle(
              color: Colors.white,
              fontSize: 26.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5),
        ),

        SizedBox(height: 6.h),

        // Role + Member Since row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.traderRole.value.isNotEmpty)
              _buildBadge(
                  controller.traderRole.value.toUpperCase(),
                  const Color(0xFF8B9BFF)),
            if (controller.traderRole.value.isNotEmpty &&
                controller.memberSince.value.isNotEmpty)
              SizedBox(width: 8.w),
            if (controller.memberSince.value.isNotEmpty)
              _buildBadge(
                  'Since ${controller.memberSince.value}',
                  Colors.white12),
          ],
        ),

        SizedBox(height: 14.h),

        // Bio
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            controller.displayBio,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white60,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.6),
          ),
        ),

        // Rating stars row
        if (controller.rating.value > 0) ...[
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (i) {
                final full = i < controller.rating.value.floor();
                final half = !full &&
                    i < controller.rating.value &&
                    controller.rating.value - i >= 0.5;
                return Icon(
                  full
                      ? Icons.star_rounded
                      : half
                          ? Icons.star_half_rounded
                          : Icons.star_border_rounded,
                  color: const Color(0xFFFFD700),
                  size: 18.sp,
                );
              }),
              SizedBox(width: 8.w),
              Text(
                '${controller.ratingDisplay} (${controller.reviewCount.value} reviews)',
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(color == Colors.white12 ? 1 : 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color == Colors.white12
                ? Colors.white38
                : const Color(0xFF8B9BFF),
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Column(
      children: [
        _shimmerBox(120.r, 120.r, circle: true),
        SizedBox(height: 16.h),
        _shimmerBox(20.h, 160.w),
        SizedBox(height: 10.h),
        _shimmerBox(14.h, 260.w),
        SizedBox(height: 6.h),
        _shimmerBox(14.h, 220.w),
      ],
    );
  }

  // ─── STATS ROW ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final stats = [
      {
        'value': controller.totalTrades.value > 0
            ? controller.totalTrades.value.toString()
            : '—',
        'label': 'TRADES',
        'icon': Icons.swap_horiz_rounded,
      },
      {
        'value': controller.ratingDisplay,
        'label': 'RATING',
        'icon': Icons.star_rounded,
      },
      {
        'value': controller.positiveDisplay,
        'label': 'POSITIVE',
        'icon': Icons.thumb_up_rounded,
      },
      {
        'value': controller.followersCount.value.toString(),
        'label': 'FOLLOWERS',
        'icon': Icons.people_rounded,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: stats
            .map((s) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _buildStatCard(
                      s['value'] as String,
                      s['label'] as String,
                      s['icon'] as IconData,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8B9BFF), size: 18.sp),
          SizedBox(height: 6.h),
          Text(val,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900)),
          SizedBox(height: 2.h),
          Text(label,
              style: TextStyle(
                  color: Colors.white24,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ─── ACTION BUTTONS ─────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    final name = controller.displayName;
    final avatar = controller.displayAvatar;
    final traderId = controller.traderId.value;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          // Message Button
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (traderId.isNotEmpty) {
                  final mc = Get.put(MessagesController());
                  final chatId = await mc.createChatRoom(traderId);
                  if (chatId != null && chatId.isNotEmpty) {
                    Get.toNamed(AppRoute.messageDetails, arguments: {
                      'chatId': chatId,
                      'name': name,
                      'avatar': avatar,
                    });
                  } else {
                    Get.toNamed(AppRoute.messageDetails, arguments: {
                      'chatId': 'mock_room_1',
                      'name': name,
                      'avatar': avatar,
                    });
                  }
                }
              },
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B9BFF),
                  borderRadius: BorderRadius.circular(28.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message_rounded, color: Colors.black, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text('Message',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Follow / Unfollow Button
          Expanded(
            child: GestureDetector(
              onTap: () => controller.toggleFollow(),
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: controller.isFollowing.value
                      ? const Color(0xFF1C1C28)
                      : const Color(0xFF8B9BFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(28.r),
                  border: Border.all(
                    color: controller.isFollowing.value
                        ? Colors.white12
                        : const Color(0xFF8B9BFF).withOpacity(0.5),
                  ),
                ),
                child: controller.isFollowLoading.value
                    ? Center(
                        child: SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF8B9BFF),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.isFollowing.value
                                ? Icons.person_remove_rounded
                                : Icons.person_add_rounded,
                            color: controller.isFollowing.value
                                ? Colors.white38
                                : const Color(0xFF8B9BFF),
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            controller.isFollowing.value
                                ? 'Following'
                                : 'Follow',
                            style: TextStyle(
                                color: controller.isFollowing.value
                                    ? Colors.white38
                                    : const Color(0xFF8B9BFF),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TABS ───────────────────────────────────────────────────────────────────

  Widget _buildTabs() {
    final tabs = [
      {'label': 'Collection', 'count': controller.products.length},
      {'label': 'Bids', 'count': controller.recentBids.length},
      {'label': 'Reviews', 'count': controller.reviews.length},
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: List.generate(
          tabs.length,
          (i) => Expanded(
            child: GestureDetector(
              onTap: () => controller.setTab(i),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tabs[i]['label'] as String,
                        style: TextStyle(
                          color: controller.activeTab.value == i
                              ? Colors.white
                              : Colors.white24,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if ((tabs[i]['count'] as int) > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: controller.activeTab.value == i
                                ? const Color(0xFF8B9BFF)
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            (tabs[i]['count'] as int).toString(),
                            style: TextStyle(
                                color: controller.activeTab.value == i
                                    ? Colors.black
                                    : Colors.white38,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 10.h),
                  if (controller.activeTab.value == i)
                    Container(
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B9BFF),
                          borderRadius: BorderRadius.circular(2.r),
                        ))
                  else
                    Container(height: 2.h, color: Colors.transparent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── TAB CONTENT ────────────────────────────────────────────────────────────

  Widget _buildTabContent() {
    switch (controller.activeTab.value) {
      case 0:
        return _buildCollectionGrid();
      case 1:
        return _buildBidsList();
      case 2:
        return _buildReviewsList();
      default:
        return const SizedBox.shrink();
    }
  }

  // Collection Grid
  Widget _buildCollectionGrid() {
    if (controller.isProductsLoading.value) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.72,
          children: List.generate(4, (_) => _buildProductShimmer()),
        ),
      );
    }
    if (controller.products.isEmpty) {
      return _buildEmptyState(
          'No items in collection', Icons.inventory_2_outlined);
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.72,
        children: controller.products
            .map((p) => _buildProductCard(p))
            .toList(),
      ),
    );
  }

  Widget _buildProductShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final title = product['title'] ?? product['name'] ?? 'Item';
    final double price =
        (product['buyNowPrice'] ?? product['price'] ?? 0).toDouble();
    final List images = product['images'] ?? [];
    final String rawImg = images.isNotEmpty ? images[0].toString() : '';
    final String img = (rawImg.isNotEmpty && !rawImg.startsWith('http') && !rawImg.startsWith('data:image/'))
        ? "${ApiUrl.imageBaseUrl}${rawImg.startsWith('/') ? rawImg : '/$rawImg'}"
        : rawImg;
    final bool allowTrade = product['allowTrade'] == true;
    final bool isSold = (product['status'] ?? '') == 'sold';
    final String productId = product['_id'] ?? product['id'] ?? '';

    return GestureDetector(
      onTap: () {
        final Map<String, dynamic> argMap = Map<String, dynamic>.from(product);
        argMap['productId'] = productId;
        argMap['sellerId'] = {
          '_id': controller.traderId.value,
          'fullName': controller.traderName.value,
          'name': controller.traderName.value,
          'avatar': controller.traderAvatar.value,
          'profile': controller.traderAvatar.value,
          'image': controller.traderAvatar.value,
          'bio': controller.traderBio.value,
          'rating': controller.rating.value > 0 ? controller.rating.value.toString() : '4.8',
        };
        Get.toNamed(AppRoute.tradeDetails, arguments: argMap);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF11111A),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.r)),
                      color: const Color(0xFF1E1E2C),
                      image: img.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(img), fit: BoxFit.cover)
                          : null,
                    ),
                    child: img.isEmpty
                        ? Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                color: Colors.white24, size: 28.sp))
                        : null,
                  ),
                  if (isSold)
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10.r)),
                        child: Text('SOLD',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                  if (allowTrade && !isSold)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                            color: const Color(0xFFD677FF).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8.r)),
                        child: Text('TRADE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 6.h),
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: const Color(0xFF8B9BFF),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bids List
  Widget _buildBidsList() {
    if (controller.isBidsLoading.value) {
      return Column(
        children: List.generate(
            3, (_) => _shimmerBox(72.h, double.infinity, margin: 16.w)),
      );
    }
    if (controller.recentBids.isEmpty) {
      return _buildEmptyState('No recent bids', Icons.gavel_rounded);
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: controller.recentBids.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _buildBidCard(controller.recentBids[i]),
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid) {
    final senderProduct = bid['senderProductId'];
    final receiverProduct = bid['receiverProductId'];
    final String sTitle = senderProduct is Map
        ? (senderProduct['title'] ?? 'Item')
        : 'Trade Item';
    final String rTitle = receiverProduct is Map
        ? (receiverProduct['title'] ?? 'Item')
        : 'Trade Item';
    final String status = bid['status'] ?? 'pending';
    final Color statusColor = status == 'accepted'
        ? const Color(0xFF4CAF50)
        : status == 'declined'
            ? const Color(0xFFFF5252)
            : const Color(0xFFFFB74D);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Offered: $sTitle',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Text('For: $rTitle',
                    style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  // Reviews List
  Widget _buildReviewsList() {
    if (controller.isReviewsLoading.value) {
      return Column(
        children: List.generate(
            3, (_) => _shimmerBox(90.h, double.infinity, margin: 16.w)),
      );
    }
    if (controller.reviews.isEmpty) {
      return _buildEmptyState('No reviews yet', Icons.star_border_rounded);
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: controller.reviews.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _buildReviewCard(controller.reviews[i]),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final int stars = (review['rating'] ?? 0) as int;
    final String comment = review['comment'] ?? review['text'] ?? '';
    final reviewer = review['reviewerId'] ?? review['reviewer'];
    final String reviewerName = reviewer is Map
        ? (reviewer['fullName'] ?? reviewer['name'] ?? 'Anonymous')
        : 'Anonymous';
    final String reviewerAvatar = reviewer is Map
        ? (reviewer['avatar'] ?? reviewer['profileImage'] ?? '')
        : '';
    final String createdAt = review['createdAt'] ?? '';
    String dateLabel = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt).toLocal();
        dateLabel = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: const Color(0xFF1E1E2C),
                backgroundImage: reviewerAvatar.isNotEmpty
                    ? NetworkImage(reviewerAvatar)
                    : null,
                child: reviewerAvatar.isEmpty
                    ? Icon(Icons.person, color: Colors.white38, size: 18.sp)
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reviewerName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700)),
                    if (dateLabel.isNotEmpty)
                      Text(dateLabel,
                          style: TextStyle(
                              color: Colors.white38, fontSize: 10.sp)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFFD700),
                    size: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(comment,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  Widget _buildEmptyState(String msg, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 56.h),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: Colors.white24, size: 44.sp),
            SizedBox(height: 14.h),
            Text(msg,
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double height, double width,
      {bool circle = false, double margin = 0}) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(
          horizontal: margin, vertical: margin > 0 ? 6.h : 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius:
            circle ? null : BorderRadius.circular(12.r),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
