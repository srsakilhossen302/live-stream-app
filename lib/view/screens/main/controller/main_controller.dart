import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../home/screen/home_screen.dart';
import '../../purchases/screen/purchases_screen.dart';
import '../../browse/screen/browse_screen.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs; // Default to Home

  final List<Widget> screens = [
    const HomeScreen(),
    const PurchasesScreen(),
    const BrowseScreen(),
    const Center(child: Text("Bidswap", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Profile", style: TextStyle(color: Colors.white))),
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
