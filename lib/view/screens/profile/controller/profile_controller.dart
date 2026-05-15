import 'package:get/get.dart';

class ProfileController extends GetxController {
  var selectedTab = 0.obs;
  final tabs = ["Listings", "Activity", "Settings"];

  var selectedActivityFilter = 0.obs;
  final activityFilters = ["All", "Purchases"];

  // Cover photo
  final coverPhotoUrl = Rxn<String>(); // null = no cover yet

  void changeCoverPhoto() {
    // Simulates picking a photo — in production hook into image_picker
    coverPhotoUrl.value =
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1200&auto=format&fit=crop';
  }

  void removeCoverPhoto() {
    coverPhotoUrl.value = null;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void changeActivityFilter(int index) {
    selectedActivityFilter.value = index;
  }
}
