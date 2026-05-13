import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateTradeController extends GetxController {
  // Your Item Fields
  final itemNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final estValueController = TextEditingController();
  
  var selectedCategory = "Watches".obs;
  var selectedCondition = "Mint".obs;

  final categories = ["Watches", "Sneakers", "Trading Cards", "Tech", "Other"];
  final conditions = ["New", "Mint", "Near Mint", "Used", "Poor"];

  // What You Want Fields
  final desiredItemController = TextEditingController();
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();
  
  var targetCategory = "Any Category".obs;
  final targetCategories = ["Any Category", "Watches", "Sneakers", "Trading Cards", "Tech"];

  void setCategory(String val) => selectedCategory.value = val;
  void setCondition(String val) => selectedCondition.value = val;
  void setTargetCategory(String val) => targetCategory.value = val;

  void postTrade() {
    // Logic for posting trade via API
    Get.back();
    Get.snackbar(
      "Success", 
      "Your trade has been posted successfully!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF8B9BFF),
      colorText: Colors.black,
    );
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
