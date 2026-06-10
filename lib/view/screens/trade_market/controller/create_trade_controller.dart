import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/helpers/shared_prefe.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/api_url.dart';

class CreateTradeController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final ImagePicker _picker = ImagePicker();

  // Your Item Fields
  final itemNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final estValueController = TextEditingController();

  var selectedCategory = "Streetwear".obs;
  var selectedCondition = "Mint".obs;

  final categories = [
    "Fine Art",
    "Sports Cards",
    "Rare Spirits",
    "Luxury Cars",
    "Electronics",
    "Streetwear",
    "TCG",
    "Digital Assets",
  ];
  final conditions = ["New", "Mint", "Near Mint", "Used", "Poor"];

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

  void setCategory(String val) => selectedCategory.value = val;
  void setCondition(String val) => selectedCondition.value = val;
  void setTargetCategory(String val) => targetCategory.value = val;

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((img) => File(img.path)));
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick images");
    }
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

    isLoading.value = true;

    try {
      final String userId = SharePrefsHelper.getString(
        SharePrefsHelper.userIdKey,
      );

      final Map<String, String> fields = {
        "title": title,
        "description": description,
        "category": selectedCategory.value,
        "condition": selectedCondition.value,
        "estValue": estValue,
        "buyNowPrice": estValue,
        "allowTrade": "true",
        "sellerId": userId,
      };

      // Exactly like profile info update, but for POST and potentially multiple images
      final response = await _apiClient.postMultipart(
        ApiUrl.products,
        fields,
        filePaths: selectedImages.map((f) => f.path).toList(),
        fieldName: 'images',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
