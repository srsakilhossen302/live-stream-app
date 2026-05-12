import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/screen/home_screen.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs; // Default to Home

  final List<Widget> screens = [
    const HomeScreen(),
    const Center(child: Text("Purchases", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Discover", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Bidswap", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Profile", style: TextStyle(color: Colors.white))),
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
