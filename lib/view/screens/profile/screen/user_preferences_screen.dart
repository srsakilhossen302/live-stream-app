import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  final List<String> selectedCategories = ["Fine Art", "Rare Spirits"];

  final List<Map<String, dynamic>> categories = [
    {
      "title": "Fine Art",
      "subtitle": "Masterpieces & curated contemporary works.",
      "icon": Icons.palette_outlined,
    },
    {
      "title": "Sports Cards",
      "subtitle": "Rare collectibles from legendary eras.",
      "icon": Icons.emoji_events_outlined,
    },
    {
      "title": "Rare Spirits",
      "subtitle": "Aged excellence and limited vintages.",
      "icon": Icons.liquor_outlined,
    },
    {
      "title": "Luxury Cars",
      "subtitle": "Exotics, classics, and hypercars.",
      "icon": Icons.directions_car_outlined,
    },
    {
      "title": "Electronics",
      "subtitle": "Horological mastery and investment watches.",
      "icon": Icons.watch_outlined,
    },
    {
      "title": "Streetwear",
      "subtitle": "Hype drops and archival garments.",
      "icon": Icons.checkroom_outlined,
    },
    {
      "title": "TCG",
      "subtitle": "First editions and historical manuscripts.",
      "icon": Icons.auto_stories_outlined,
    },
    {
      "title": "Digital Assets",
      "subtitle": "Web3 collectibles and digital fine art.",
      "icon": Icons.layers_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Preferences",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 1),
          ),
        ),
        body: GridView.builder(
          padding: EdgeInsets.all(24.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategories.contains(category["title"]);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedCategories.remove(category["title"]);
                  } else {
                    selectedCategories.add(category["title"]);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF161622),
                  borderRadius: BorderRadius.circular(28.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF8B9BFF) : Colors.white.withOpacity(0.04),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(category["icon"], color: Colors.white70, size: 24.sp),
                        ),
                        if (isSelected)
                          Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B9BFF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, color: Colors.black, size: 12.sp),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      category["title"],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      category["subtitle"],
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
