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

  void setCategory(String val) => selectedCategory.value = val;
  void setCondition(String val) => selectedCondition.value = val;
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

      // Convert images to base64 strings
      final List<String> base64Images = [];
      for (var file in selectedImages) {
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);
        final mimeType = file.path.split('.').last.toLowerCase();
        base64Images.add("data:image/$mimeType;base64,$base64Str");
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
        "images": base64Images,
      };

      final response = await _apiClient.postData(
        ApiUrl.products,
        requestBody,
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
