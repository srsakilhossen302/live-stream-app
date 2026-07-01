import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';
import '../../profile/controller/profile_controller.dart';

class CreateTradeController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final ImagePicker _picker = ImagePicker();

  // Your Item Fields
  final itemNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final estValueController = TextEditingController();

  var selectedCategory = "Streetwear".obs;
  var selectedCondition = "Mint".obs;

  final RxList<String> categories = <String>[
    "Fine Art",
    "Sports Cards",
    "Rare Spirits",
    "Luxury Cars",
    "Electronics",
    "Streetwear",
    "TCG",
    "Digital Assets",
  ].obs;
  final conditions = ["Mint", "Near Mint", "Excellent", "Good", "Fair"];

  // Image handling
  final RxList<File> selectedImages = <File>[].obs;
  final RxBool isLoading = false.obs;

  // What You Want Fields
  final desiredItemController = TextEditingController();
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();

  var targetCategory = "Any Category".obs;
  final targetCategories = [
    "Any Category",
    "Watches",
    "Sneakers",
    "Trading Cards",
    "Tech",
  ];

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void setCategory(String val) => selectedCategory.value = val;
  void setCondition(String val) => selectedCondition.value = val;
  
  Future<void> fetchCategories() async {
    try {
      final response = await _apiClient.getData(ApiUrl.category);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'] ?? [];
        final parsed = data.map((item) => item['name']?.toString() ?? "").where((name) => name.isNotEmpty).toList();
        if (parsed.isNotEmpty) {
          categories.assignAll(parsed);
          if (!categories.contains(selectedCategory.value)) {
            selectedCategory.value = parsed[0];
          }
        }
      }
    } catch (e) {
      Get.log("Error fetching categories: $e");
    }
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 20,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((img) => File(img.path)));
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick images");
    }
  }

  void setTargetCategory(String val) => targetCategory.value = val;

  Future<String?> _uploadImageToS3(File file) async {
    try {
      final fileName = file.path.split('/').last.split('\\').last;
      final ext = fileName.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

      // 1. Get S3 Presigned URL
      final response = await _apiClient.postData("/upload/presign", {
        "fileName": fileName,
        "contentType": contentType,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final uploadUrl = body['data']['url'].toString();

          // 2. PUT request directly to S3
          final fileBytes = await file.readAsBytes();
          final s3Response = await http.put(
            Uri.parse(uploadUrl),
            headers: {
              "Content-Type": contentType,
            },
            body: fileBytes,
          );

          if (s3Response.statusCode == 200 || s3Response.statusCode == 201) {
            // Retrieve actual file URL from presigned URL
            final s3Url = uploadUrl.split('?').first;
            return s3Url;
          }
        }
      }
    } catch (e) {
      Get.log("S3 upload error: $e");
    }
    return null;
  }

  Future<void> postTrade() async {
    final title = itemNameController.text.trim();
    final description = descriptionController.text.trim();
    final estValue = estValueController.text.trim();

    if (title.isEmpty || description.isEmpty || estValue.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (selectedImages.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select at least one image",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final String userId = SharePrefsHelper.getString(
        SharePrefsHelper.userIdKey,
      );

      final List<String> imageUrls = [];

      // S3 upload with local base64 fallback
      for (var file in selectedImages) {
        final s3Url = await _uploadImageToS3(file);
        if (s3Url != null && s3Url.isNotEmpty) {
          imageUrls.add(s3Url);
        } else {
          // Fallback to Base64 String
          final bytes = await file.readAsBytes();
          final base64Str = base64Encode(bytes);
          final mimeType = file.path.split('.').last.toLowerCase();
          imageUrls.add("data:image/$mimeType;base64,$base64Str");
        }
      }

      final Map<String, dynamic> requestBody = {
        "title": title,
        "description": description,
        "category": selectedCategory.value,
        "condition": selectedCondition.value,
        "estValue": double.tryParse(estValue) ?? 0.0,
        "buyNowPrice": double.tryParse(estValue) ?? 0.0,
        "allowTrade": true,
        "sellerId": userId,
        "images": imageUrls,
      };

      final response = await _apiClient.postData(
        ApiUrl.products,
        requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh the profile controller if active in memory to display the new item instantly
        try {
          if (Get.isRegistered<ProfileController>()) {
            Get.find<ProfileController>().fetchProfileData();
          }
        } catch (_) {}

        Get.back();
        Get.snackbar(
          "Success",
          "Your trade has been posted successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF8B9BFF),
          colorText: Colors.black,
        );
      } else {
        String errorMessage = "Failed to post trade";
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? errorMessage;
        } catch (_) {}
        Get.snackbar(
          "Error",
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    itemNameController.dispose();
    descriptionController.dispose();
    estValueController.dispose();
    desiredItemController.dispose();
    minValueController.dispose();
    maxValueController.dispose();
    super.onClose();
  }
}

