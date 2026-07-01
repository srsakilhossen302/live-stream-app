import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

class ProfileController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final ImagePicker _picker = ImagePicker();

  var selectedTab = 0.obs;
  final tabs = ["Listings", "Activity", "Settings"];

  var selectedActivityFilter = 0.obs;
  final activityFilters = ["All", "Purchases"];

  // Profile data
  final RxBool isLoading = false.obs;
  final RxString name = "User Name".obs;
  final RxString username = "@username".obs;
  final RxString description = "Bio description...".obs;
  final RxString profileImageUrl = "".obs;
  final RxString coverPhotoUrl = "".obs;
  final RxBool isVerified = false.obs;
  final RxDouble rating = 9.0.obs;
  final RxInt reviewsCount = 124.obs;
  final RxInt activeCount = 0.obs;
  final RxInt soldCount = 0.obs;

  // User listings
  final RxList<dynamic> userListings = <dynamic>[].obs;

  // Activity data
  final RxList<dynamic> notificationsList = <dynamic>[].obs;
  final RxList<dynamic> purchasesList = <dynamic>[].obs;
  final RxBool isActivityLoading = false.obs;

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
        name.value = data['fullName'] ?? "User Name";
        username.value = "@${data['username'] ?? "username"}";
        description.value = data['description'] ?? "No bio added yet.";

        // Handle profile image
        final profilePath = data['profile'] ?? "";
        if (profilePath.isNotEmpty) {
          profileImageUrl.value = (profilePath.startsWith('http') || profilePath.startsWith('data:image/'))
              ? profilePath
              : "${ApiUrl.imageBaseUrl}${profilePath.startsWith('/') ? profilePath : '/$profilePath'}";
        }

        // Handle cover photo
        final coverPath = data['coverPhoto'] ?? "";
        if (coverPath.isNotEmpty) {
          coverPhotoUrl.value = (coverPath.startsWith('http') || coverPath.startsWith('data:image/'))
              ? coverPath
              : "${ApiUrl.imageBaseUrl}${coverPath.startsWith('/') ? coverPath : '/$coverPath'}";
        }

        // Handle additional fields
        isVerified.value = data['isVerified'] ?? false;
        if (data['rating'] != null) {
          rating.value = (data['rating'] as num).toDouble();
        }
        reviewsCount.value = data['reviewsCount'] ?? 124;

        // Fetch products listed by this user and activity logs
        final userId = data['id'] ?? data['_id'] ?? SharePrefsHelper.getString(SharePrefsHelper.userIdKey);
        if (userId != null && userId.isNotEmpty) {
          await fetchUserListings(userId);
          await fetchActivityData(userId);
        }
      }
    } catch (e) {
      Get.log("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserListings(String userId) async {
    try {
      final response = await _apiClient.getData("${ApiUrl.products}?sellerId=$userId");
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body)['data'] as List;
        userListings.assignAll(list);

        // Update active and sold counts based on listings
        activeCount.value = list.where((item) => item['status'] == 'live' || item['status'] == 'active' || item['isSold'] != true).length;
        soldCount.value = list.where((item) => item['status'] == 'sold' || item['isSold'] == true).length;
      }
    } catch (e) {
      Get.log("Error fetching user listings: $e");
    }
  }

  Future<void> fetchActivityData(String userId) async {
    isActivityLoading.value = true;
    try {
      await Future.wait([
        fetchNotifications(),
        fetchPurchases(userId),
      ]);
    } finally {
      isActivityLoading.value = false;
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await _apiClient.getData(ApiUrl.myNotifications);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body)['data'] as List;
        notificationsList.assignAll(list);
      }
    } catch (e) {
      Get.log("Error fetching notifications: $e");
    }
  }

  Future<void> fetchPurchases(String userId) async {
    try {
      final response = await _apiClient.getData("${ApiUrl.userOrders}?userId=$userId&role=buyer");
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body)['data'] as List;
        purchasesList.assignAll(list);
      }
    } catch (e) {
      Get.log("Error fetching purchases: $e");
    }
  }

  Future<void> updateImage(ImageSource source, {required bool isCover}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        isLoading.value = true;

        final response = await _apiClient.patchMultipart(
          ApiUrl.profile,
          {}, // No text fields for just image update
          filePath: image.path,
          fieldName: isCover ? 'coverPhoto' : 'images',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar(
            "Success",
            "${isCover ? 'Cover' : 'Profile'} photo updated!",
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
          );
          fetchProfileData(); // Refresh UI
        } else {
          Get.snackbar(
            "Error",
            "Failed to update image",
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void changeActivityFilter(int index) {
    selectedActivityFilter.value = index;
  }
}
