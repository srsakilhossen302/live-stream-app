import 'dart:convert';
import 'package:get/get.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

class HomeController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  var selectedCategoryIndex = 0.obs;
  final RxString fullName = "User".obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
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
        }
      }
    } catch (e) {
      Get.log("Error fetching profile on Home: $e");
    } finally {
      isLoading.value = false;
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

  final List<LiveItemModel> liveItems = [
    LiveItemModel(
      title: "HypeBeast Sneakers...",
      curator: "KicksLovers_05",
      viewers: "1.2K",
      image:
          "https://images.unsplash.com/photo-1552346154-21d32810aba3?auto=format&fit=crop&q=80&w=300",
    ),
    LiveItemModel(
      title: "Graded Pokemon Grail",
      curator: "TCG_Master",
      viewers: "400",
      image:
          "https://images.unsplash.com/photo-1613771404721-1f92d799e49f?auto=format&fit=crop&q=80&w=300",
    ),
    LiveItemModel(
      title: "Archive Designer Outlet",
      curator: "Stack_Gallery",
      viewers: "2.3K",
      image:
          "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&q=80&w=300",
    ),
    LiveItemModel(
      title: "Timepiece Tuesday",
      curator: "ChronoSelect",
      viewers: "3.6K",
      image:
          "https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&q=80&w=300",
    ),
  ];

  void onCategorySelected(int index) {
    selectedCategoryIndex.value = index;
  }
}

class LiveItemModel {
  final String title;
  final String curator;
  final String viewers;
  final String image;

  LiveItemModel({
    required this.title,
    required this.curator,
    required this.viewers,
    required this.image,
  });
}
