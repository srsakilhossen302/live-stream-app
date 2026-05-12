import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  var selectedCategories = <int>{}.obs;

  final List<CategoryModel> categories = [
    CategoryModel(id: 1, title: "Fine Art", subtitle: "Masterpieces & curated contemporary works.", icon: Icons.palette_outlined),
    CategoryModel(id: 2, title: "Sports Cards", subtitle: "Rare collectibles from legendary eras.", icon: Icons.emoji_events_outlined),
    CategoryModel(id: 3, title: "Rare Spirits", subtitle: "Aged excellence and limited vintages.", icon: Icons.wine_bar_outlined),
    CategoryModel(id: 4, title: "Luxury Cars", subtitle: "Exotics, classics, and hypercars.", icon: Icons.directions_car_outlined),
    CategoryModel(id: 5, title: "Electronics", subtitle: "Horological mastery and investment watches.", icon: Icons.watch_outlined),
    CategoryModel(id: 6, title: "Streetwear", subtitle: "Hype drops and archival garments.", icon: Icons.checkroom_outlined),
    CategoryModel(id: 7, title: "TCG", subtitle: "First editions and historical manuscripts.", icon: Icons.menu_book_outlined),
    CategoryModel(id: 8, title: "Digital Assets", subtitle: "Web3 collectibles and digital fine art.", icon: Icons.layers_outlined),
  ];

  void toggleCategory(int id) {
    if (selectedCategories.contains(id)) {
      selectedCategories.remove(id);
    } else {
      selectedCategories.add(id);
    }
  }

  void onContinue() {
    Get.log("Selected Categories: $selectedCategories");
  }

  void onSkip() {
    Get.log("Skip Clicked");
  }

  void onClose() {
    Get.back();
  }
}

class CategoryModel {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;

  CategoryModel({required this.id, required this.title, required this.subtitle, required this.icon});
}
