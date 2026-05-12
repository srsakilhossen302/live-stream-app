import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/app_route.dart';
import '../../../../core/utils/app_images.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  var currentPage = 0.obs;

  List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      image: AppImages.onboarding1,
      title: "Discover live auctions, explore unique items, and bid instantly — all in one place.",
      subtitle: "Join real-time events, connect with sellers, and never miss your next winning bid.",
      description: "",
    ),
    OnboardingModel(
      image: AppImages.onboarding2,
      title: "Bid Instantly",
      subtitle: "Join auctions, chat live, and win exciting deals.",
      description: "",
    ),
    OnboardingModel(
      image: AppImages.onboarding3,
      title: "Sell & Stream",
      subtitle: "Host live auctions and sell to a global audience.",
      description: "",
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void onGetStarted() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.offNamed(AppRoute.login);
    }
  }

  void onSkip() {
    Get.offNamed(AppRoute.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingModel {
  final String image;
  final String title;
  final String subtitle;
  final String description;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
