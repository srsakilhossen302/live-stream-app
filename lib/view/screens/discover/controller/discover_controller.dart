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
      final response = await _apiClient.getData(ApiUrl.liveStreams);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        final parsedShows = data.map((item) {
          final title = item['title'] ?? "Live Show";
          final hostName = item['curator'] ?? item['sellerId']?['fullName'] ?? "Curator";
          
          String imageUrl = "";
          final imagePath = item['image'] ?? "";
          if (imagePath.isNotEmpty) {
            imageUrl = imagePath.startsWith('http')
                ? imagePath
                : "${ApiUrl.imageBaseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}";
          } else {
            imageUrl = "https://images.unsplash.com/photo-1614850523296-d8c1af93d400?q=80&w=1000";
          }

          return <String, dynamic>{
            "title": title,
            "host": "Hosted by $hostName",
            "viewers": "${item['viewers'] ?? '0'}",
            "image": imageUrl,
            "raw": item,
          };
        }).toList();
        liveShows.assignAll(parsedShows);

        final parsedFeatured = data.take(2).map((item) {
          final title = item['title'] ?? "Live Item";
          final priceVal = item['startingBid'] ?? 0;
          
          String imageUrl = "";
          final imagePath = item['image'] ?? "";
          if (imagePath.isNotEmpty) {
            imageUrl = imagePath.startsWith('http')
                ? imagePath
                : "${ApiUrl.imageBaseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}";
          } else {
            imageUrl = "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=400";
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
            imageUrl = imagePath.startsWith('http')
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
            imageUrl = imagePath.startsWith('http')
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
