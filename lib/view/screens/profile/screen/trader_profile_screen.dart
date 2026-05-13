import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';

class TraderProfileScreen extends StatelessWidget {
  const TraderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Trader Profile",
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.share_outlined, color: Colors.white, size: 22.sp),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              
              // Profile Header
              _buildProfileHeader(),
              
              SizedBox(height: 32.h),
              
              // Stats Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("120", "TRADES"),
                    _buildStatCard("4.8/5", "RATING"),
                    _buildStatCard("99%", "POSITIVE"),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Expanded(child: _buildActionButton("Message", const Color(0xFF8B9BFF), Colors.black)),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildActionButton("Follow", const Color(0xFF1C1C28), Colors.white)),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Tabs
              _buildTabs(),
              
              SizedBox(height: 24.h),
              
              // Collection Grid
              _buildCollectionGrid(),
              
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60.r,
              backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop"),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(color: Color(0xFF0F0B1E), shape: BoxShape.circle),
                child: Icon(Icons.verified, color: const Color(0xFF8B9BFF), size: 24.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          "@Julian_D",
          style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            "Elite collector and trader of rare streetwear and luxury watches. Based in NY. Trusted for secure, authenticated swaps.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String val, String label) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color bgColor, Color textColor) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28.r),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 16.sp, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem("Trade Collection", true),
          _buildTabItem("Recent Bids", false),
          _buildTabItem("Reviews", false),
        ],
      ),
    );
  }

  Widget _buildTabItem(String text, bool isActive) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white24,
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (isActive) ...[
          SizedBox(height: 8.h),
          Container(height: 2.h, width: 80.w, color: const Color(0xFF8B9BFF)),
        ],
      ],
    );
  }

  Widget _buildCollectionGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 20.h,
        crossAxisSpacing: 20.w,
        childAspectRatio: 0.7,
        children: [
          _buildCollectionCard(
            "Nike Dunk Low 'Retro'",
            "\$180",
            "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
            true,
            "TRADE",
          ),
          _buildCollectionCard(
            "Supreme Classic Tee",
            "\$85",
            "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=500",
            false,
            "SOLD",
          ),
          _buildCollectionCard(
            "Seiko Prospex 'Blue'",
            "\$420",
            "https://images.unsplash.com/photo-1524592094714-0f0654e20314?q=80&w=500",
            true,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(String title, String price, String img, bool isLive, String? tag) {
    return GestureDetector(
      onTap: () {
        if (isLive) {
          Get.toNamed('/live_stream');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF11111A),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(color: const Color(0xFF8B9BFF).withOpacity(0.8), borderRadius: BorderRadius.circular(6.r)),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Colors.white, size: 6.sp),
                            SizedBox(width: 4.w),
                            Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                  if (tag == "SOLD")
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12.r)),
                        child: Text("SOLD", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                      if (tag == "TRADE")
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(color: const Color(0xFFD677FF).withOpacity(0.2), borderRadius: BorderRadius.circular(6.r)),
                          child: Text("TRADE", style: TextStyle(color: const Color(0xFFD677FF), fontSize: 8.sp, fontWeight: FontWeight.w900)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
