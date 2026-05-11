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
                            color: const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: _buildInternalCardUI(index, page.image),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Main Text (Below Card)
                      _buildTitle(page.title, index),
                      const SizedBox(height: 18),
                      // Subtext
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
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
              height: 62,
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
                          : "Get Started",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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

  Widget _buildInternalCardUI(int index, String imagePath) {
    if (index == 0) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
          Positioned(
            top: 24,
            left: 24,
            child: _buildBadge("LIVE EVENT", Colors.red),
          ),
          Positioned(
            bottom: 40,
            left: 28,
            right: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: Color(0xFF8B9BFF), size: 28),
                    const SizedBox(width: 8),
                    Text(
                      "AuctionLive",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      TextSpan(text: "Welcome to\n", style: TextStyle(color: Colors.white)),
                      TextSpan(text: "AuctionLive", style: TextStyle(color: Color(0xFF5D5FEF))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (index == 1) {
      return Column(
        children: [
          // Top Image
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: _buildBadge("LIVE NOW", Colors.red, bgColor: const Color(0xFFFF6B6B).withOpacity(0.6)),
                ),
              ],
            ),
          ),
          // Bottom Content
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: const Color(0xFF1E1E2C),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Vanguard",
                            style: TextStyle(color: Color(0xFF8B9BFF), fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "GT-8",
                            style: TextStyle(color: Color(0xFF8B9BFF), fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Current High Bid",
                            style: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                        ],
                      ),
                      const Text(
                        "\$142,500",
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Chat Bubbles
                  Row(
                    children: [
                      const CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=1")),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Just placed my bid! This\none is mine. 🚀",
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B4468),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "Counter-bid incoming! 💎",
                                style: TextStyle(color: Color(0xFF8B9BFF), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=2")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (index == 2) {
       return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage("assets/images/GoriImg- onboding3 ar.png"),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            child: _buildBadge("LIVE BIDDING", const Color(0xFF6200EE)),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CURRENT BID", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  Text("\$12,450.00", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildBadge(String text, Color dotColor, {Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title, int index) {
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
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
        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1.1, fontFamily: 'Inter'),
        children: [
          TextSpan(text: primary, style: const TextStyle(color: Colors.white)),
          TextSpan(text: secondary, style: TextStyle(color: secondaryColor)),
        ],
      ),
    );
  }
}
