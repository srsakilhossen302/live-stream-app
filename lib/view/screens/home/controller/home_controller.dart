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

  // Dynamic Category Items & Titles List
  final RxList<HomeCategoryItem> categoriesList = <HomeCategoryItem>[
    HomeCategoryItem(id: "", name: "All"),
  ].obs;

  final RxList<String> categories = <String>[
    "All",
    "Collectibles",
    "Streetwear",
    "Sneakers",
    "Watches",
    "Art",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
    fetchLiveStreams();
    fetchCategories().then((_) {
      fetchProducts();
    });
  }

  Future<void> fetchCategories() async {
    try {
      Get.log("🔄 [Home] Fetching categories from API: ${ApiUrl.category}");
      var response = await _apiClient.getData(ApiUrl.category);

      if (response.statusCode != 200) {
        Get.log("🔄 [Home] Primary category endpoint failed (${response.statusCode}), trying fallback: ${ApiUrl.popularCategories}");
        response = await _apiClient.getData(ApiUrl.popularCategories);
      }

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        List data = [];
        if (resBody['data'] is List) {
          data = resBody['data'];
        } else if (resBody['categories'] is List) {
          data = resBody['categories'];
        }

        if (data.isNotEmpty) {
          final List<HomeCategoryItem> fetched = [
            HomeCategoryItem(id: "", name: "All"),
          ];

          for (var item in data) {
            if (item is Map) {
              final String id = (item['_id'] ?? item['id'] ?? '').toString();
              final String name = (item['name'] ?? item['title'] ?? '').toString();
              final String image = (item['image'] ?? '').toString();
              final String icon = (item['icon'] ?? '').toString();

              if (name.isNotEmpty) {
                fetched.add(HomeCategoryItem(
                  id: id,
                  name: name,
                  image: image,
                  icon: icon,
                ));
              }
            }
          }

          categoriesList.assignAll(fetched);
          categories.assignAll(fetched.map((c) => c.name).toList());
          Get.log("✅ [Home] Successfully loaded ${categoriesList.length} categories from API");
        }
      } else {
        Get.log("⚠️ [Home] Category fetch status: ${response.statusCode}");
      }
    } catch (e) {
      Get.log("❌ [Home] Error fetching categories: $e");
    }
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

  // Fetch Products based on selected category & active status
  Future<void> fetchProducts() async {
    isProductsLoading.value = true;
    try {
      final int idx = selectedCategoryIndex.value;
      final selectedCat = (idx >= 0 && idx < categoriesList.length)
          ? categoriesList[idx]
          : HomeCategoryItem(id: "", name: "All");

      String url;
      const String statusQuery = "status=active";

      if (selectedCat.id.isNotEmpty) {
        url = "${ApiUrl.product}?category=${selectedCat.id}&$statusQuery";
      } else if (selectedCat.name.isNotEmpty && selectedCat.name != "All") {
        url = "${ApiUrl.product}?category=${Uri.encodeComponent(selectedCat.name)}&$statusQuery";
      } else {
        url = "${ApiUrl.product}?$statusQuery";
      }

      Get.log("🔄 [Home] Fetching products from: $url");
      var response = await _apiClient.getData(url);

      if (response.statusCode != 200) {
        String fallbackUrl;
        if (selectedCat.id.isNotEmpty) {
          fallbackUrl = "${ApiUrl.products}?category=${selectedCat.id}&$statusQuery";
        } else if (selectedCat.name.isNotEmpty && selectedCat.name != "All") {
          fallbackUrl = "${ApiUrl.products}?category=${Uri.encodeComponent(selectedCat.name)}&$statusQuery";
        } else {
          fallbackUrl = "${ApiUrl.products}?$statusQuery";
        }
        Get.log("🔄 [Home] /product query failed (${response.statusCode}), trying fallback: $fallbackUrl");
        response = await _apiClient.getData(fallbackUrl);
      }

      if (response.statusCode != 200) {
        String noStatusUrl = selectedCat.id.isNotEmpty
            ? "${ApiUrl.products}?category=${selectedCat.id}"
            : (selectedCat.name != "All" ? "${ApiUrl.products}?category=${Uri.encodeComponent(selectedCat.name)}" : ApiUrl.products);
        Get.log("🔄 [Home] Active status query failed, trying standard endpoint: $noStatusUrl");
        response = await _apiClient.getData(noStatusUrl);
      }

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        List rawList = [];

        if (resBody['data'] is List) {
          rawList = resBody['data'];
        } else if (resBody['data'] is Map) {
          final dataMap = resBody['data'];
          if (dataMap['doc'] is List) {
            rawList = dataMap['doc'];
          } else if (dataMap['products'] is List) {
            rawList = dataMap['products'];
          } else if (dataMap['result'] is List) {
            rawList = dataMap['result'];
          }
        } else if (resBody['products'] is List) {
          rawList = resBody['products'];
        }

        products.value = rawList.map((e) => Map<String, dynamic>.from(e)).toList();
        Get.log("✅ [Home] Loaded ${products.length} products for category: ${selectedCat.name}");
      } else {
        Get.log("⚠️ [Home] Failed to fetch products. Status: ${response.statusCode}");
        products.clear();
      }
    } catch (e) {
      Get.log("❌ [Home] Error fetching products: $e");
      products.clear();
    } finally {
      isProductsLoading.value = false;
    }
  }

  void onCategorySelected(int index) {
    selectedCategoryIndex.value = index;
    fetchProducts();
  }

  Future<void> refreshHome() async {
    await Future.wait([
      fetchProfileData(),
      fetchLiveStreams(),
      fetchCategories(),
    ]);
    await fetchProducts();
  }
}

class HomeCategoryItem {
  final String id;
  final String name;
  final String image;
  final String icon;

  HomeCategoryItem({
    required this.id,
    required this.name,
    this.image = "",
    this.icon = "",
  });
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
