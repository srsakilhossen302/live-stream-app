import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';

class MakeOfferScreen extends StatelessWidget {
  const MakeOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
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
                                  _buildNestedMiniItem("OFFERING", "Off-White Tee", "Chicago Edition Capsule", true),
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
                                  _buildNestedMiniItem("LOOKING FOR", "Rolex Submariner Date", "40mm Steel Design", false, showTag: true),
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
                                        Text("Off-White Tee", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
                                        SizedBox(height: 4.h),
                                        Text("LIMITED EDITION \"METEOR\" PRINT", style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text("\$450", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 24.sp, fontWeight: FontWeight.w900)),
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
                          SizedBox(height: 80.h), // Increased gap between cards
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
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161622),
                          borderRadius: BorderRadius.circular(32.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 320.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(24.r),
                                image: const DecorationImage(
                                  image: NetworkImage("https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=1000"),
                                  fit: BoxFit.cover,
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
                                      Text("Rolex Datejust 41", style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900)),
                                      SizedBox(height: 4.h),
                                      Text("OYSTERSTEEL & JUBILEE BRACELET", style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text("\$12,400", style: TextStyle(color: const Color(0xFFBD8BFF), fontSize: 24.sp, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
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
                            Text("-\$11,950", style: TextStyle(color: const Color(0xFFFF4B6E), fontSize: 28.sp, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        Container(
                          height: 56.r,
                          width: 56.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4B6E).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.trending_down_rounded, color: const Color(0xFFFF4B6E), size: 24.sp),
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
                        "Your offer value is significantly lower than the requested item. Consider adding a cash supplement to increase success rate.",
                        style: TextStyle(color: Colors.white38, fontSize: 13.sp, height: 1.6, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Container(
                      width: double.infinity,
                      height: 64.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      alignment: Alignment.center,
                      child: Text("+ ADD CASH TO OFFER", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B9BFF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                    elevation: 0,
                  ),
                  child: Row(
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
        ),
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
              Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
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
