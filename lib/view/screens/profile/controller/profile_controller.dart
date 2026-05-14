import 'package:get/get.dart';

class ProfileController extends GetxController {
  var selectedTab = 0.obs;
  final tabs = ["Listings", "Activity", "Settings"];

  var selectedActivityFilter = 0.obs;
  final activityFilters = ["All", "Purchases"];

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void changeActivityFilter(int index) {
    selectedActivityFilter.value = index;
  }
}
