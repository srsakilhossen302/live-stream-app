import 'package:get/get.dart';

class MessagesController extends GetxController {
  var selectedFilter = 0.obs;
  final filters = ["All", "Unread", "Orders", "Trades"];

  void changeFilter(int index) {
    selectedFilter.value = index;
  }
}
