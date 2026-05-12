import 'package:get/get.dart';
import '../model/category_model.dart';

class BrowseController extends GetxController {
  var selectedFilter = 0.obs;
  final filters = ["Recommended", "Popular", "A-Z"];

  final categories = <CategoryModel>[
    CategoryModel(
      title: "Trading Card Games",
      subtitle: "Pokemon, Magic: The Gathering, Sports",
      image: "https://images.unsplash.com/photo-1613771404721-1f92d799e49f?q=80&w=2069&auto=format&fit=crop",
      liveCount: "1.2 Live",
    ),
    CategoryModel(
      title: "Sneakers & Streetwear",
      subtitle: "Jordan, Nike, Supreme, Off-White",
      image: "https://images.unsplash.com/photo-1552346154-21d32810aba3?q=80&w=2070&auto=format&fit=crop",
      liveCount: "842 Live",
    ),
    CategoryModel(
      title: "Luxury Watches",
      subtitle: "Rolex, Patek Philippe, Audemars Piguet",
      image: "https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=2080&auto=format&fit=crop",
      liveCount: "156 Live",
    ),
  ].obs;

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
