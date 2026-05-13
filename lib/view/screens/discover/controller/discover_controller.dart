import 'package:get/get.dart';

class DiscoverController extends GetxController {
  var selectedFilter = 0.obs;
  final filters = ["All", "Live Shows", "Trade Market"];

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
