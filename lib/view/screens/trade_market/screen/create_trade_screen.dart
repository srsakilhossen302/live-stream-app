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
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900),
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
                style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              SizedBox(height: 8.h),
              Text(
                "Curate your exchange. Offer excellence,\nreceive value.",
                style: TextStyle(color: Colors.white60, fontSize: 16.sp, fontWeight: FontWeight.w600, height: 1.4),
              ),
              
              SizedBox(height: 40.h),
              _buildSectionTitle("Your Item"),
              SizedBox(height: 8.h),
              Text(
                "Present your masterpiece. High-quality imagery and detailed provenance attract the most prestigious offers.",
                style: TextStyle(color: Colors.white38, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4),
              ),

              SizedBox(height: 24.h),
              _buildUploadBox(),

              SizedBox(height: 32.h),
              _buildInputContainer([
                _buildLabel("ITEM NAME"),
                _buildTextField("e.g. Vintage 1964 Chronograph", controller.itemNameController),
                SizedBox(height: 24.h),
                _buildLabel("DESCRIPTION"),
                _buildTextField("Detail the narrative and\nspecifications of your item...", controller.descriptionController, maxLines: 3),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _buildSelectable(
                        "CATEGORY", 
                        controller.selectedCategory.value, 
                        () => _showPicker("Select Category", controller.categories, (val) => controller.setCategory(val))
                      )),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Obx(() => _buildSelectable(
                        "CONDITION", 
                        controller.selectedCondition.value, 
                        () => _showPicker("Select Condition", controller.conditions, (val) => controller.setCondition(val))
                      )),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildLabel("EST. VALUE (\$)"),
                _buildTextField("5000", controller.estValueController, keyboardType: TextInputType.number),
              ]),

              SizedBox(height: 40.h),
              _buildSectionTitle("What You Want"),
              SizedBox(height: 8.h),
              Text(
                "Define your desire. Whether it's a specific rarity or a broad category, be clear on what completes the swap.",
                style: TextStyle(color: Colors.white38, fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4),
              ),

              SizedBox(height: 24.h),
              _buildInputContainer([
                _buildLabel("DESIRED ITEM / INTERESTS"),
                _buildTextField("Seeking modern horology\nor rare photography", controller.desiredItemController),
                SizedBox(height: 24.h),
                Obx(() => _buildSelectable(
                  "TARGET CATEGORY", 
                  controller.targetCategory.value, 
                  () => _showPicker("Select Target Category", controller.targetCategories, (val) => controller.setTargetCategory(val))
                )),
                SizedBox(height: 24.h),
                _buildLabel("TARGET VALUE RANGE (\$)"),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Min", controller.minValueController, keyboardType: TextInputType.number)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text("—", style: TextStyle(color: Colors.white24, fontSize: 16.sp)),
                    ),
                    Expanded(child: _buildTextField("Max", controller.maxValueController, keyboardType: TextInputType.number)),
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
      style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 22.sp, fontWeight: FontWeight.w900),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      height: 380.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, color: const Color(0xFF8B9BFF), size: 32.sp),
          SizedBox(height: 12.h),
          Text(
            "UPLOAD PRIME VISUALS",
            style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        label,
        style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController textController, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white24, fontSize: 15.sp, fontWeight: FontWeight.w600),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF8B9BFF))),
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
                Text(value, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                Icon(Icons.keyboard_arrow_down, color: Colors.white24, size: 20.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(String title, List<String> options, Function(String) onSelect) {
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
            Text(title, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 24.h),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: options.map((opt) {
                    IconData icon;
                    String listings;
                    switch (opt) {
                      case "Sneakers": icon = Icons.directions_run; listings = "1234 listings"; break;
                      case "Trading Cards": icon = Icons.style; listings = "892 listings"; break;
                      case "Tech": icon = Icons.devices; listings = "678 listings"; break;
                      case "Watches": icon = Icons.watch; listings = "456 listings"; break;
                      default: icon = Icons.category_outlined; listings = "0 listings";
                    }
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      leading: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12.r)),
                        child: Icon(icon, color: const Color(0xFF8B9BFF), size: 20.sp),
                      ),
                      title: Text(opt, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      subtitle: Text(listings, style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.w500)),
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
      child: ElevatedButton(
        onPressed: () => controller.postTrade(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B9BFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.r)),
          elevation: 0,
        ),
        child: Text(
          "Post Trade",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
