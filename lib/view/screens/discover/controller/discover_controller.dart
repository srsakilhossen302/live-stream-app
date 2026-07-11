import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

class DiscoverController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final RxBool isLoading = false.obs;

  var selectedFilter = 0.obs;
  final filters = ["All", "Live Shows", "Trade Market"];

  // Search parameters
  final searchQuery = "".obs;
  final searchController = TextEditingController();

  // Lists for dynamic API integration
  final liveShows = <Map<String, dynamic>>[].obs;
  final featuredLiveItems = <Map<String, dynamic>>[].obs;
  final featuredTrades = <Map<String, dynamic>>[].obs;
  final tradeMarketItems = <Map<String, dynamic>>[].obs;

  final topSellers = [
    {
      "rank": "01",
      "name": "EliteVault",
      "rating": "99% Positive",
      "image": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200",
    },
    {
      "rank": "02",
      "name": "SoleConnect",
      "rating": "98% Positive",
      "image": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200",
    },
  ].obs;

  final trendingTags = ["#jordan1", "#charizard-psa10", "#rolex-daytona", "#grail-sneakers", "#luxury-trading"].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDiscoverData();
  }

  Future<void> fetchDiscoverData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchLiveShows(),
        fetchTradeMarketItems(),
      ]);
    } catch (e) {
      Get.log("Error loading discover data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLiveShows() async {
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
          String hostAvatarUrl = "";
          if (seller is Map) {
            final avatarPath = seller['profile'] ?? seller['profileImage'] ?? seller['image'] ?? seller['profileImageUrl'] ?? seller['avatar'] ?? "";
            if (avatarPath.isNotEmpty) {
              hostAvatarUrl = avatarPath.startsWith('http')
                  ? avatarPath
                  : "${ApiUrl.imageBaseUrl}${avatarPath.startsWith('/') ? avatarPath : '/$avatarPath'}";
            }
          }

          return <String, dynamic>{
            "title": title,
            "host": "Hosted by $hostName",
            "viewers": "${item['viewers'] ?? '0'}",
            "image": imageUrl,
            "hostAvatar": hostAvatarUrl,
            "raw": item,
          };
        }).toList();
        liveShows.assignAll(parsedShows);

        final parsedFeatured = data.take(2).map((item) {
          final prod = item['productId'];
          final title = item['title'] ?? ((prod is Map) ? (prod['title'] ?? prod['name']) : null) ?? "Live Item";
          final priceVal = (prod is Map) 
              ? (prod['startingBid'] ?? prod['buyNowPrice'] ?? prod['price'] ?? 0) 
              : (item['startingBid'] ?? 0);
          
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

          return <String, dynamic>{
            "category": (item['category'] ?? "AUCTION").toString().toUpperCase(),
            "title": title,
            "price": "\$${priceVal.toString()}",
            "image": imageUrl,
            "badge": "LIVE NOW",
            "raw": item,
          };
        }).toList();
        featuredLiveItems.assignAll(parsedFeatured);
      }
    } catch (e) {
      Get.log("Error loading live shows: $e");
    }
  }

  Future<void> fetchTradeMarketItems() async {
    try {
      final response = await _apiClient.getData(ApiUrl.products);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        
        final parsedMarket = data.map((item) {
          final title = item['title'] ?? "Unknown Item";
          final priceVal = item['estValue'] ?? 0;
          final condition = item['condition'] ?? "GOOD";
          
          String imageUrl = "";
          final imagesList = item['images'];
          if (imagesList != null && imagesList is List && imagesList.isNotEmpty) {
            final imagePath = imagesList[0].toString();
            imageUrl = (imagePath.startsWith('http') || imagePath.startsWith('data:image/'))
                ? imagePath
                : "${ApiUrl.imageBaseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}";
          }
          if (imageUrl.isEmpty) {
            imageUrl = "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500";
          }
          
          return <String, dynamic>{
            "title": title,
            "value": "\$${priceVal.toString()}",
            "lookingFor": (item['description'] ?? "Trade for equal value").toString(),
            "tag": condition.toString().toUpperCase(),
            "image": imageUrl,
            "raw": item,
          };
        }).toList();
        tradeMarketItems.assignAll(parsedMarket);

        final parsedFeatured = data.take(3).map((item) {
          final title = item['title'] ?? "Unknown Item";
          final priceVal = item['estValue'] ?? 0;
          
          String imageUrl = "";
          final imagesList = item['images'];
          if (imagesList != null && imagesList is List && imagesList.isNotEmpty) {
            final imagePath = imagesList[0].toString();
            imageUrl = (imagePath.startsWith('http') || imagePath.startsWith('data:image/'))
                ? imagePath
                : "${ApiUrl.imageBaseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}";
          }
          if (imageUrl.isEmpty) {
            imageUrl = "https://images.unsplash.com/photo-1552346154-21d32810aba3?q=80&w=1000";
          }
          
          return <String, dynamic>{
            "title": title,
            "price": "Starting Est. \$${priceVal.toString()}",
            "image": imageUrl,
            "raw": item,
          };
        }).toList();
        featuredTrades.assignAll(parsedFeatured);
      }
    } catch (e) {
      Get.log("Error loading trade market items: $e");
    }
  }

  List<Map<String, dynamic>> get filteredTradeMarketItems {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return tradeMarketItems;
    return tradeMarketItems.where((item) {
      final title = item['title']?.toString().toLowerCase() ?? "";
      final tag = item['tag']?.toString().toLowerCase() ?? "";
      final lookingFor = item['lookingFor']?.toString().toLowerCase() ?? "";
      return title.contains(query) || tag.contains(query) || lookingFor.contains(query);
    }).toList();
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
