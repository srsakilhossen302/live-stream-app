import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../controller/create_trade_controller.dart';

class CreateTradeScreen extends GetView<CreateTradeController> {
  const CreateTradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CreateTradeController());
    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Create Trade",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                "Create Trade",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Curate your exchange. Offer excellence,\nreceive value.",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 40.h),
              _buildSectionTitle("Your Item"),
              SizedBox(height: 8.h),
              Text(
                "Present your masterpiece. High-quality imagery and detailed provenance attract the most prestigious offers.",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 24.h),
              _buildUploadBox(),

              SizedBox(height: 32.h),
              _buildInputContainer([
                _buildLabel("Item name"),
                _buildTextField(
                  "e.g. Vintage 1964 Chronograph",
                  controller.itemNameController,
                ),
                SizedBox(height: 24.h),
                _buildLabel("Description"),
                _buildTextField(
                  "Detail the narrative and\nspecifications of your item...",
                  controller.descriptionController,
                  maxLines: 3,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildSelectable(
                          "Category",
                          controller.selectedCategory.value,
                          () => _showPicker(
                            "Select Category",
                            controller.categories,
                            (val) => controller.setCategory(val),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Obx(
                        () => _buildSelectable(
                          "Condition",
                          controller.selectedCondition.value,
                          () => _showPicker(
                            "Select Condition",
                            controller.conditions,
                            (val) => controller.setCondition(val),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildLabel("Estimated value"),
                _buildTextField(
                  "5000",
                  controller.estValueController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 28.h),

                // ── Buy Now Price ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Buy now price",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            "Allow instant purchase at a fixed price",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => GestureDetector(
                      onTap: () => controller.enableBuyNow.toggle(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48.w,
                        height: 26.h,
                        decoration: BoxDecoration(
                          color: controller.enableBuyNow.value
                              ? const Color(0xFF8B9BFF)
                              : Colors.white12,
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: controller.enableBuyNow.value
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.all(3.r),
                            width: 20.r,
                            height: 20.r,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
                Obx(() => controller.enableBuyNow.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          _buildTextField(
                            "e.g. 4500",
                            controller.buyNowPriceController,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B9BFF).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFF8B9BFF).withOpacity(0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.bolt_rounded, color: const Color(0xFF8B9BFF), size: 14.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    "Buyers can instantly purchase your item at this price without trade negotiation.",
                                    style: TextStyle(
                                      color: const Color(0xFF8B9BFF).withOpacity(0.85),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),

              ]),

              SizedBox(height: 40.h),
              _buildSectionTitle("What You Want"),
              SizedBox(height: 8.h),
              Text(
                "Define your desire. Whether it's a specific rarity or a broad category, be clear on what completes the swap.",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 24.h),
              _buildInputContainer([
                _buildLabel("What you're looking for"),
                _buildTextField(
                  "Seeking modern horology\nor rare photography",
                  controller.desiredItemController,
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => _buildSelectable(
                    "Target category",
                    controller.targetCategory.value,
                    () => _showPicker(
                      "Select Target Category",
                      controller.targetCategories,
                      (val) => controller.setTargetCategory(val),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                _buildLabel("Target value range"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Min",
                        controller.minValueController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        "—",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildTextField(
                        "Max",
                        controller.maxValueController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ]),

              SizedBox(height: 48.h),
              _buildPostButton(),
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF8B9BFF),
        fontSize: 22.sp,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildUploadBox() {
    return Obx(() {
      final images = controller.selectedImages;
      final selectedIndex = controller.selectedImageIndex.value;

      if (images.isEmpty) {
        return GestureDetector(
          onTap: () => controller.pickImages(),
          child: Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF161622),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: const Color(0xFF8B9BFF),
                  size: 32.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  "Upload prime visuals",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Preview Area
          Container(
            height: 280.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF161622),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    images[selectedIndex],
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: GestureDetector(
                      onTap: () => controller.removeImage(selectedIndex),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Previewing ${selectedIndex + 1} of ${images.length}",
                        style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Horizontal Thumbnail Row
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: images.length + 1,
              itemBuilder: (context, index) {
                if (index == images.length) {
                  // Add More Button at the end
                  return GestureDetector(
                    onTap: () => controller.pickImages(),
                    child: Container(
                      width: 80.h,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11111A),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFF8B9BFF).withOpacity(0.2), width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: const Color(0xFF8B9BFF), size: 20.sp),
                          SizedBox(height: 4.h),
                          Text("Add", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 10.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }

                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => controller.selectedImageIndex.value = index,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 80.h,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF8B9BFF) : Colors.white.withOpacity(0.05),
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: Image.file(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -4.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 10.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInputContainer(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF11111A),
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController textController, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white24,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF8B9BFF)),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      ),
    );
  }

  Widget _buildSelectable(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          Container(
            padding: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white24,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: const Color(0xFF11111A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 24.h),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: options.map((opt) {
                    IconData icon;
                    String listings;
                    switch (opt) {
                      case "Sneakers":
                        icon = Icons.directions_run;
                        listings = "1234 listings";
                        break;
                      case "Trading Cards":
                        icon = Icons.style;
                        listings = "892 listings";
                        break;
                      case "Tech":
                        icon = Icons.devices;
                        listings = "678 listings";
                        break;
                      case "Watches":
                        icon = Icons.watch;
                        listings = "456 listings";
                        break;
                      default:
                        icon = Icons.category_outlined;
                        listings = "0 listings";
                    }
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      leading: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          icon,
                          color: const Color(0xFF8B9BFF),
                          size: 20.sp,
                        ),
                      ),
                      title: Text(
                        opt,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        listings,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        onSelect(opt);
                        Get.back();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPostButton() {
    return Container(
      width: double.infinity,
      height: 64.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B9BFF).withOpacity(0.3),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.postTrade(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B9BFF),
            disabledBackgroundColor: const Color(0xFF8B9BFF).withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.r),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  "Post Trade",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }
}
