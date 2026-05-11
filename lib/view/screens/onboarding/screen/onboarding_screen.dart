import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());
    return CustomBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Featured Content (PageView)
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = controller.onboardingPages[index];
                  return Column(
                    children: [
                      // Featured Card
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            image: DecorationImage(
                              image: AssetImage(page.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      _buildTitle(page.title, index),
                      const SizedBox(height: 16),
                      // Subtitle
                      Text(
                        page.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      if (page.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buttons
            Obx(() => SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () => controller.onGetStarted(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B9BFF),
                  foregroundColor: const Color(0xFF0F0B1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.currentPage.value == controller.onboardingPages.length - 1
                          ? "Get Started"
                          : "Continue",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, weight: 800),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () => controller.onSkip(),
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title, int index) {
    if (index == 0) {
      return Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.w900,
          height: 1.1,
        ),
      );
    } else if (index == 1) {
      return RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 1.1,
            fontFamily: 'Inter',
          ),
          children: [
            TextSpan(text: "Bid ", style: TextStyle(color: Colors.white)),
            TextSpan(text: "Instantly", style: TextStyle(color: Color(0xFF8B9BFF))),
          ],
        ),
      );
    } else {
      return RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 1.1,
            fontFamily: 'Inter',
          ),
          children: [
            TextSpan(text: "Sell & ", style: TextStyle(color: Colors.white)),
            TextSpan(text: "Stream", style: TextStyle(color: Color(0xFFCC8BFF))),
          ],
        ),
      );
    }
  }
}
