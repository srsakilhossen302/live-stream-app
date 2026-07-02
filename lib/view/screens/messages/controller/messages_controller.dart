import 'package:get/get.dart';

class MessagesController extends GetxController {
  var selectedFilter = 0.obs;
  var isLoading = true.obs;
  final filters = ["All", "Unread", "Orders", "Trades"];

  @override
  void onInit() {
    super.onInit();
    // Simulate loading to show shimmer effect
    Future.delayed(const Duration(milliseconds: 1500), () {
      isLoading.value = false;
    });
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
