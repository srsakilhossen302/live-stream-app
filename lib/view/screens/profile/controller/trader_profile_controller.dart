import 'dart:convert';
import 'package:get/get.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../../../../data/helpers/shared_prefe.dart';

class TraderProfileController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // ─── Profile ────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final traderId = ''.obs;
  final traderName = ''.obs;
  final traderAvatar = ''.obs;
  final traderBio = ''.obs;
  final traderRole = ''.obs;
  final isVerified = false.obs;
  final memberSince = ''.obs;

  // ─── Stats ──────────────────────────────────────────────────────────────────
  final totalTrades = 0.obs;
  final rating = 0.0.obs;
  final reviewCount = 0.obs;
  final positivePercent = 0.obs;
  final followersCount = 0.obs;
  final totalOrders = 0.obs;

  // ─── Follow State ────────────────────────────────────────────────────────────
  final isFollowing = false.obs;
  final isFollowLoading = false.obs;

  // ─── Products (Trade Collection) ─────────────────────────────────────────────
  final isProductsLoading = true.obs;
  final products = <Map<String, dynamic>>[].obs;

  // ─── Recent Bids / Trade Offers ──────────────────────────────────────────────
  final isBidsLoading = true.obs;
  final recentBids = <Map<String, dynamic>>[].obs;

  // ─── Reviews ─────────────────────────────────────────────────────────────────
  final isReviewsLoading = true.obs;
  final reviews = <Map<String, dynamic>>[].obs;

  // ─── Active Tab ──────────────────────────────────────────────────────────────
  final activeTab = 0.obs; // 0=Collection, 1=Recent Bids, 2=Reviews

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    traderId.value = args['id'] ?? args['_id'] ?? '';

    // Prefill from navigation args immediately (instant render)
    traderName.value = args['name'] ?? args['fullName'] ?? '';
    traderBio.value = args['bio'] ?? args['description'] ?? '';
    traderAvatar.value = args['avatar'] ?? args['image'] ?? '';

    if (traderId.value.isNotEmpty) {
      _loadAll();
    } else {
      isLoading.value = false;
      isProductsLoading.value = false;
      isBidsLoading.value = false;
      isReviewsLoading.value = false;
    }
  }

  void _loadAll() {
    fetchTraderProfile();
    fetchTraderProducts();
    fetchRecentBids();
    fetchReviews();
  }

  // ─── FETCH PROFILE ──────────────────────────────────────────────────────────

  Future<void> fetchTraderProfile() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final response =
          await _apiClient.getData('${ApiUrl.users}/${traderId.value}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] ?? body;

        traderName.value =
            data['fullName'] ?? data['name'] ?? traderName.value;
        traderBio.value =
            data['bio'] ?? data['description'] ?? traderBio.value;
        traderAvatar.value = data['avatar'] ??
            data['profileImage'] ??
            data['image'] ??
            traderAvatar.value;
        traderRole.value = data['role'] ?? '';
        isVerified.value = data['isVerified'] == true;

        // Member since
        final createdAt = data['createdAt'] ?? '';
        if (createdAt.isNotEmpty) {
          try {
            final dt = DateTime.parse(createdAt).toLocal();
            memberSince.value =
                '${_monthName(dt.month)} ${dt.year}';
          } catch (_) {}
        }

        // Stats block
        final stats = data['stats'] ?? {};
        totalTrades.value =
            (stats['totalTrades'] ?? data['totalTrades'] ?? 0) as int;
        totalOrders.value =
            (stats['totalOrders'] ?? data['totalOrders'] ?? 0) as int;

        final r = stats['rating'] ?? data['rating'] ?? data['averageRating'];
        rating.value = r != null ? (r as num).toDouble() : 0.0;

        reviewCount.value =
            (stats['reviewCount'] ?? data['reviewCount'] ?? 0) as int;

        final pos =
            stats['positivePercent'] ?? data['positivePercent'] ?? data['positiveRate'];
        positivePercent.value =
            pos != null ? (pos as num).toInt() : 0;

        // Followers
        final followers = data['followers'];
        if (followers is List) {
          followersCount.value = followers.length;
        } else if (followers is int) {
          followersCount.value = followers;
        } else {
          followersCount.value =
              (data['followersCount'] ?? 0) as int;
        }

        // Check if current user follows this trader
        final currentUserId =
            SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
        if (followers is List) {
          isFollowing.value = followers.any((f) =>
              f == currentUserId ||
              (f is Map &&
                  (f['_id'] == currentUserId || f['id'] == currentUserId)));
        }

        Get.log('✅ [TraderProfile] Loaded: ${traderName.value}');
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load profile (${response.statusCode})';
        Get.log('⚠️ [TraderProfile] Status: ${response.statusCode}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Network error. Please try again.';
      Get.log('❌ [TraderProfile] fetchProfile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── FETCH PRODUCTS ─────────────────────────────────────────────────────────

  Future<void> fetchTraderProducts() async {
    isProductsLoading.value = true;
    try {
      final response = await _apiClient
          .getData('${ApiUrl.products}?sellerId=${traderId.value}&limit=20');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List rawList =
            body['data'] ?? body['products'] ?? body['result'] ?? [];
        products.value =
            rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        Get.log('✅ [TraderProfile] Products: ${products.length}');
      }
    } catch (e) {
      Get.log('❌ [TraderProfile] fetchProducts error: $e');
    } finally {
      isProductsLoading.value = false;
    }
  }

  // ─── FETCH RECENT BIDS / TRADES ─────────────────────────────────────────────

  Future<void> fetchRecentBids() async {
    isBidsLoading.value = true;
    try {
      final response = await _apiClient.getData(
          '${ApiUrl.tradeOffers}?userId=${traderId.value}&type=sent&limit=10');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List rawList =
            body['data'] ?? body['trades'] ?? body['offers'] ?? [];
        recentBids.value =
            rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        Get.log('✅ [TraderProfile] Bids: ${recentBids.length}');
      }
    } catch (e) {
      Get.log('❌ [TraderProfile] fetchBids error: $e');
    } finally {
      isBidsLoading.value = false;
    }
  }

  // ─── FETCH REVIEWS ──────────────────────────────────────────────────────────

  Future<void> fetchReviews() async {
    isReviewsLoading.value = true;
    try {
      final response = await _apiClient
          .getData('${ApiUrl.review}/provider/${traderId.value}');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List rawList =
            body['data'] ?? body['reviews'] ?? [];
        reviews.value =
            rawList.map((e) => Map<String, dynamic>.from(e)).toList();

        // Recompute rating from reviews if profile didn't have it
        if (reviews.isNotEmpty && rating.value == 0.0) {
          final avg = reviews
                  .map((r) => (r['rating'] ?? 0) as num)
                  .reduce((a, b) => a + b) /
              reviews.length;
          rating.value = avg.toDouble();
          reviewCount.value = reviews.length;

          final pos = reviews.where((r) => (r['rating'] ?? 0) >= 4).length;
          positivePercent.value =
              ((pos / reviews.length) * 100).toInt();
        }

        Get.log('✅ [TraderProfile] Reviews: ${reviews.length}');
      }
    } catch (e) {
      Get.log('❌ [TraderProfile] fetchReviews error: $e');
    } finally {
      isReviewsLoading.value = false;
    }
  }

  // ─── FOLLOW / UNFOLLOW ──────────────────────────────────────────────────────
  // Note: Backend has no /users/follow endpoint yet — works as local UI toggle

  Future<void> toggleFollow() async {
    if (isFollowLoading.value) return;
    isFollowLoading.value = true;

    // Small delay for button animation feel
    await Future.delayed(const Duration(milliseconds: 300));

    isFollowing.value = !isFollowing.value;
    followersCount.value = isFollowing.value
        ? followersCount.value + 1
        : (followersCount.value - 1).clamp(0, 9999999);

    Get.log('✅ [TraderProfile] Follow toggled locally: ${isFollowing.value}');
    isFollowLoading.value = false;
  }


  // ─── REFRESH ALL ────────────────────────────────────────────────────────────

  Future<void> refreshAll() async {
    await Future.wait([
      fetchTraderProfile(),
      fetchTraderProducts(),
      fetchRecentBids(),
      fetchReviews(),
    ]);
  }

  // ─── TAB ────────────────────────────────────────────────────────────────────

  void setTab(int index) => activeTab.value = index;

  // ─── COMPUTED GETTERS ────────────────────────────────────────────────────────

  String get displayName {
    final n = traderName.value;
    if (n.isEmpty) return '@Unknown';
    return n.startsWith('@') ? n : '@$n';
  }

  String get displayBio {
    final b = traderBio.value;
    return b.isNotEmpty ? b : 'Trusted trader. Verified for secure swaps.';
  }

  String get displayAvatar => traderAvatar.value;

  String get ratingDisplay =>
      rating.value > 0 ? rating.value.toStringAsFixed(1) : '—';

  String get positiveDisplay =>
      positivePercent.value > 0 ? '${positivePercent.value}%' : '—';

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
