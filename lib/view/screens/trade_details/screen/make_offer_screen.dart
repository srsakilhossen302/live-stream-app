import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';
import '../../../../data/services/api_url.dart';
import '../controller/make_offer_controller.dart';

class MakeOfferScreen extends GetView<MakeOfferController> {
  const MakeOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MakeOfferController());

    return CustomBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Get.back(),
          ),
          title: Text("Make Offer", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 1),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8B9BFF)));
          }

          final sellerProduct = controller.sellerProduct;
          if (sellerProduct.isEmpty) {
            return Center(
              child: Text(
                "No product details found.",
                style: TextStyle(color: Colors.white38, fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            );
          }

          final selectedProduct = controller.selectedUserProduct.value;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("THE TRADE", style: TextStyle(color: Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text("PENDING REVIEW", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        // Top Card: Trade Summary
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF161622),
                            borderRadius: BorderRadius.circular(32.r),
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(20.r),
                                padding: EdgeInsets.all(24.r),
                                height: 280.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B0B13),
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                child: Column(
                                  children: [
                                    _buildNestedMiniItem(
                                      "OFFERING",
                                      sellerProduct['title'] ?? 'Product',
                                      (sellerProduct['category'] ?? 'APPAREL').toString().toUpperCase(),
                                      true,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20.h),
                                      child: Container(
                                        height: 32.r,
                                        width: 32.r,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.swap_vert_rounded, color: Colors.white24, size: 16.sp),
                                      ),
                                    ),
                                    _buildNestedMiniItem(
                                      "LOOKING FOR",
                                      sellerProduct['lookingFor'] ?? 'Equal Value Swaps',
                                      "Est. Value: \$${controller.sellerProductValue.toInt()}",
                                      false,
                                      showTag: true,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(sellerProduct['title'] ?? 'Product', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
                                          SizedBox(height: 4.h),
                                          Text(
                                            (sellerProduct['description'] ?? 'Exclusive trade item').toString().toUpperCase(),
                                            style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text("\$${controller.sellerProductValue.toInt()}", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 24.sp, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Gap with centered Swap Icon
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(height: 80.h),
                            Positioned(
                              child: Container(
                                height: 64.r,
                                width: 64.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B9BFF),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B9BFF).withOpacity(0.4),
                                      blurRadius: 30.r,
                                      spreadRadius: 2.r,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.swap_vert_rounded, color: const Color(0xFF161622), size: 32.sp),
                              ),
                            ),
                          ],
                        ),
                        
                        // Bottom Card: Your Item Detail
                        GestureDetector(
                          onTap: () => _showProductSelectionBottomSheet(context),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161622),
                              borderRadius: BorderRadius.circular(32.r),
                              border: Border.all(color: const Color(0xFF8B9BFF).withOpacity(0.1), width: 1),
                            ),
                            child: selectedProduct == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 32.h),
                                      Icon(Icons.add_photo_alternate_outlined, color: Colors.white24, size: 48.sp),
                                      SizedBox(height: 16.h),
                                      Text("Choose from your Listings", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8.h),
                                      Text("Tap to select a product to offer", style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
                                      SizedBox(height: 32.h),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 320.h,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(24.r),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(24.r),
                                          child: _buildProductImage(
                                            selectedProduct['images'] != null && (selectedProduct['images'] as List).isNotEmpty
                                                ? selectedProduct['images'][0].toString()
                                                : "",
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 24.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(selectedProduct['title'] ?? 'Product', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  "${(selectedProduct['category'] ?? 'APPAREL').toString().toUpperCase()} • ${(selectedProduct['condition'] ?? 'BRAND NEW').toString().toUpperCase()}",
                                                  style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Text("\$${controller.userProductValue.toInt()}", style: TextStyle(color: const Color(0xFFBD8BFF), fontSize: 24.sp, fontWeight: FontWeight.w900)),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 32.h),
                
                // Value Delta Card
                Container(
                  padding: EdgeInsets.all(28.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161622),
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("VALUE DELTA", style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              SizedBox(height: 10.h),
                              Text(
                                _formatDelta(controller.valueDelta),
                                style: TextStyle(
                                  color: controller.valueDelta < 0 ? const Color(0xFFFF4B6E) : const Color(0xFF22C55E),
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 56.r,
                            width: 56.r,
                            decoration: BoxDecoration(
                              color: (controller.valueDelta < 0 ? const Color(0xFFFF4B6E) : const Color(0xFF22C55E)).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.valueDelta < 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                              color: controller.valueDelta < 0 ? const Color(0xFFFF4B6E) : const Color(0xFF22C55E),
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          controller.valueDelta < 0
                              ? "Your offer value is significantly lower than the requested item. Consider adding a cash supplement to increase success rate."
                              : "Your offer value matches or exceeds the requested item. This is a very strong trade proposal!",
                          style: TextStyle(color: Colors.white38, fontSize: 13.sp, height: 1.6, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      GestureDetector(
                        onTap: () => _showAddCashDialog(context),
                        child: Container(
                          width: double.infinity,
                          height: 64.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                            borderRadius: BorderRadius.circular(32.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            controller.cashSupplement.value > 0
                                ? "CASH SUPPLEMENT: \$${controller.cashSupplement.value.toInt()}"
                                : "+ ADD CASH TO OFFER",
                            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 48.h),
                
                // Final Send Offer Button
                Container(
                  width: double.infinity,
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B9BFF).withOpacity(0.35),
                        blurRadius: 40.r,
                        spreadRadius: -5.r,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: (controller.isSubmitting.value || selectedProduct == null)
                        ? null
                        : () => controller.sendOffer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B9BFF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFF8B9BFF).withOpacity(0.3),
                    ),
                    child: controller.isSubmitting.value
                        ? const Center(child: CircularProgressIndicator(color: Colors.black))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("SEND OFFER", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              SizedBox(width: 16.w),
                              Icon(Icons.send_rounded, size: 22.sp),
                            ],
                          ),
                  ),
                ),
                
                SizedBox(height: 60.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _formatDelta(double delta) {
    final absVal = delta.abs().toInt();
    final sign = delta < 0 ? "-" : "+";
    return "$sign\$$absVal";
  }

  void _showAddCashDialog(BuildContext context) {
    final TextEditingController cashInputController = TextEditingController(
      text: controller.cashSupplement.value > 0 ? controller.cashSupplement.value.toInt().toString() : "",
    );
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF11111A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Text("Add Cash Supplement", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter the cash amount you'd like to add to this trade offer:", style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
            SizedBox(height: 16.h),
            TextField(
              controller: cashInputController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixText: "\$ ",
                prefixStyle: TextStyle(color: const Color(0xFF8B9BFF), fontWeight: FontWeight.bold, fontSize: 16.sp),
                hintText: "0.00",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF161622),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: const BorderSide(color: Color(0xFF8B9BFF))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: Colors.white54, fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(cashInputController.text) ?? 0.0;
              controller.updateCashSupplement(amount);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B9BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text("Apply", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showProductSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: const Color(0xFF11111A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            Text("Select Your Trade Item", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
            SizedBox(height: 8.h),
            Text("Choose an item from your collection to offer.", style: TextStyle(color: Colors.white38, fontSize: 13.sp, fontWeight: FontWeight.w500)),
            SizedBox(height: 24.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 350.h),
              child: Obx(() {
                if (controller.userProducts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text("You have no listed items.", style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.userProducts.length,
                  itemBuilder: (context, index) {
                    final p = Map<String, dynamic>.from(controller.userProducts[index]);
                    final title = p['title'] ?? 'Product';
                    final valStr = p['estValue'] ?? p['buyNowPrice'] ?? '0';
                    final value = "\$$valStr";
                    final img = p['images'] != null && (p['images'] as List).isNotEmpty ? p['images'][0].toString() : "";
                    final isSelected = controller.selectedUserProduct.value != null &&
                        (controller.selectedUserProduct.value!['_id'] ?? controller.selectedUserProduct.value!['id']) == (p['_id'] ?? p['id']);

                    return GestureDetector(
                      onTap: () {
                        controller.selectProduct(p);
                        Get.back();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E1E2C) : const Color(0xFF161622),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: isSelected ? const Color(0xFF8B9BFF).withOpacity(0.3) : Colors.transparent),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60.r,
                              height: 60.r,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12.r)),
                              child: _buildProductImage(img),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 4.h),
                                  Text("Value: $value", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 13.sp, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: const Color(0xFF8B9BFF), size: 24.sp),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildProductImage(String imgStr, {BoxFit fit = BoxFit.cover}) {
    if (imgStr.isEmpty) {
      return Image.network(
        "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
        fit: fit,
      );
    }
    
    if (imgStr.startsWith('data:image/') && imgStr.contains('base64,')) {
      try {
        final base64Content = imgStr.split('base64,').last;
        final bytes = base64Decode(base64Content);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Image.network(
            "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
            fit: fit,
          ),
        );
      } catch (_) {
        return Image.network(
          "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
          fit: fit,
        );
      }
    }
    
    final cleanUrl = imgStr.startsWith('http')
        ? imgStr
        : "${ApiUrl.imageBaseUrl}${imgStr.startsWith('/') ? imgStr : '/$imgStr'}";

    return Image.network(
      cleanUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Image.network(
        "https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=500",
        fit: fit,
      ),
    );
  }

  Widget _buildNestedMiniItem(String label, String title, String subtitle, bool isOffering, {bool showTag = false}) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: isOffering ? const Color(0xFF8B9BFF) : const Color(0xFFBD8BFF),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
              SizedBox(height: 6.h),
              Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Flexible(child: Text(subtitle.toUpperCase(), style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (showTag) ...[
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBD8BFF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text("TOP TRADER", style: TextStyle(color: const Color(0xFFBD8BFF), fontSize: 8.sp, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Icon(Icons.north_east_rounded, color: Colors.white.withOpacity(0.05), size: 18.sp),
      ],
    );
  }
}
