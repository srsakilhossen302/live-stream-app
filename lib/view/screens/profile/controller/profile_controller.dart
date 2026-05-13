import 'package:get/get.dart';

class ProfileController extends GetxController {
  var selectedTab = 0.obs;
  final tabs = ["Listings", "Activity", "Settings"];

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
