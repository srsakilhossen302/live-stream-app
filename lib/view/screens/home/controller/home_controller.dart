import 'dart:convert';
import 'package:get/get.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../../../../data/services/socket_service.dart';

class HomeController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  var selectedCategoryIndex = 0.obs;
  final RxString fullName = "User".obs;
  final RxBool isLoading = false.obs;

  final RxList<LiveItemModel> liveItems = <LiveItemModel>[].obs;

  // Dynamic Products List
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxBool isProductsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
    fetchLiveStreams();
    fetchProducts();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.getData(ApiUrl.profile);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final String full = data['fullName'] ?? "User";
        // Extract only the first name
        fullName.value = full.split(" ").first;

        // Save User ID to SharedPreferences
        final String userId = data['id'] ?? data['_id'] ?? "";
        if (userId.isNotEmpty) {
          await SharePrefsHelper.setString(SharePrefsHelper.userIdKey, userId);
          // Initialize Socket.io connection since we have userId now
          try {
            Get.find<SocketService>().initSocket();
          } catch (e) {
            Get.log("Socket connection failed to initialize: $e");
          }
        }
      }
    } catch (e) {
      Get.log("Error fetching profile on Home: $e");
    }
  }

  Future<void> fetchLiveStreams() async {
    try {
      final response = await _apiClient.getData("${ApiUrl.liveStreams}?status=live");
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        final parsedShows = data.where((item) => item['status'] == 'live').map((item) {
          final title = item['title'] ?? "Live Show";
          final hostName = item['curator'] ?? item['sellerId']?['fullName'] ?? "Curator";
          
          String imageUrl = "";
          String imagePath = item['image'] ?? "";
          if (imagePath.isEmpty && item['productId'] is Map) {
            final prod = item['productId'];
            final List prodImages = prod['images'] ?? [];
            if (prodImages.isNotEmpty) {
              imagePath = prodImages[0].toString();
            } else {
              imagePath = prod['image'] ?? prod['coverImage'] ?? "";
            }
          }

          if (imagePath.isNotEmpty) {
            imageUrl = imagePath.startsWith('http')
                ? imagePath
                : "${ApiUrl.imageBaseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}";
          } else {
            imageUrl = "";
          }

          final seller = item['sellerId'];
          String avatarUrl = "";
          if (seller is Map) {
            final avatarPath = seller['profile'] ?? seller['profileImage'] ?? seller['image'] ?? seller['profileImageUrl'] ?? seller['avatar'] ?? "";
            if (avatarPath.isNotEmpty) {
              avatarUrl = avatarPath.startsWith('http')
                  ? avatarPath
                  : "${ApiUrl.imageBaseUrl}${avatarPath.startsWith('/') ? avatarPath : '/$avatarPath'}";
            }
          }

          return LiveItemModel(
            title: title,
            curator: hostName,
            viewers: "${item['viewersCount'] ?? item['viewers'] ?? '0'}",
            image: imageUrl,
            curatorAvatar: avatarUrl,
            raw: item,
          );
        }).toList();
        
        liveItems.assignAll(parsedShows);
      }
    } catch (e) {
      Get.log("Error fetching live streams on Home: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Products based on selected category
  Future<void> fetchProducts() async {
    isProductsLoading.value = true;
    try {
      final category = categories[selectedCategoryIndex.value];
      String url = ApiUrl.products;
      if (category != "All") {
        url = "${ApiUrl.products}?category=${Uri.encodeComponent(category)}";
      }

      final response = await _apiClient.getData(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        products.value = data.map((e) => Map<String, dynamic>.from(e)).toList();
        Get.log("✅ [Home] Loaded ${products.length} products for category: $category");
      }
    } catch (e) {
      Get.log("❌ [Home] Error fetching products: $e");
    } finally {
      isProductsLoading.value = false;
    }
  }

  final List<String> categories = [
    "All",
    "Collectibles",
    "Streetwear",
    "Sneakers",
    "Watches",
    "Art",
  ];

  void onCategorySelected(int index) {
    selectedCategoryIndex.value = index;
    fetchProducts();
  }

  Future<void> refreshHome() async {
    await Future.wait([
      fetchProfileData(),
      fetchLiveStreams(),
      fetchProducts(),
    ]);
  }
}

class LiveItemModel {
  final String title;
  final String curator;
  final String viewers;
  final String image;
  final String curatorAvatar;
  final Map<String, dynamic>? raw;

  LiveItemModel({
    required this.title,
    required this.curator,
    required this.viewers,
    required this.image,
    this.curatorAvatar = "",
    this.raw,
  });
}
