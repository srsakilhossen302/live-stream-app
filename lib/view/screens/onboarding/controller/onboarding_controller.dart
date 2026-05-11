import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Add state variables here
  
  void onGetStarted() {
    // Navigate to next screen or perform action
    Get.log("Get Started Clicked");
  }

  void onSkip() {
    // Skip onboarding
    Get.log("Skip Clicked");
  }
}
