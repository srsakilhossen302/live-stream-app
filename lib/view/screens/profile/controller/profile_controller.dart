import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
          final formattedPath = profilePath.startsWith('/')
              ? profilePath
              : '/$profilePath';
          profileImageUrl.value = "${ApiUrl.imageBaseUrl}$formattedPath";
        }

        // Handle cover photo
        final coverPath = data['coverPhoto'] ?? "";
        if (coverPath.isNotEmpty) {
          final formattedCoverPath = coverPath.startsWith('/')
              ? coverPath
              : '/$coverPath';
          coverPhotoUrl.value = "${ApiUrl.imageBaseUrl}$formattedCoverPath";
        }
      }
    } catch (e) {
      Get.log("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
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
