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
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            image: DecorationImage(
                              image: AssetImage(page.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _buildInternalCardUI(index),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title (Below Card)
                      _buildTitle(page.title, index),
                      const SizedBox(height: 16),
                      // Subtitle
                      Text(
                        page.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: index == 0 ? Colors.white38 : Colors.white70,
                          fontSize: index == 0 ? 14 : 16,
                          fontWeight: index == 0 ? FontWeight.normal : FontWeight.w500,
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
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
            
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

  Widget _buildInternalCardUI(int index) {
    if (index == 0) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: _buildBadge("LIVE EVENT", Colors.red),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      "AuctionLive",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Welcome to\nAuctionLive",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildBadge(String text, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
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
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      );
    }
    
    String primary = "";
    String secondary = "";
    Color secondaryColor = Colors.white;
    
    if (index == 1) {
      primary = "Bid ";
      secondary = "Instantly";
      secondaryColor = const Color(0xFF8B9BFF);
    } else {
      primary = "Sell & ";
      secondary = "Stream";
      secondaryColor = const Color(0xFFCC8BFF);
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, height: 1.1, fontFamily: 'Inter'),
        children: [
          TextSpan(text: primary, style: const TextStyle(color: Colors.white)),
          TextSpan(text: secondary, style: TextStyle(color: secondaryColor)),
        ],
      ),
    );
  }
}
