import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../global/widgets/custom_background.dart';

class TradeOfferScreen extends StatefulWidget {
  const TradeOfferScreen({super.key});

  @override
  State<TradeOfferScreen> createState() => _TradeOfferScreenState();
}

class _TradeOfferScreenState extends State<TradeOfferScreen> {
  // Countdown timer
  int _secondsLeft = 4 * 3600 + 12 * 60 + 45; // 04h 12m 45s
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final h = _secondsLeft ~/ 3600;
    final m = (_secondsLeft % 3600) ~/ 60;
    final s = _secondsLeft % 60;
    return '${h.toString().padLeft(2, '0')}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
  }

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
            "New Offer",
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900),
          ),
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
              SizedBox(height: 24.h),

              // Subtitle
              Text(
                "A high-value bid has been received for your listing.",
                style: TextStyle(color: Colors.white38, fontSize: 13.sp, fontWeight: FontWeight.w600, height: 1.5),
              ),

              SizedBox(height: 32.h),

              // Trade Cards
              _buildTradeCards(),

              SizedBox(height: 32.h),

              // Trader Info
              _buildTraderInfo(),

              SizedBox(height: 24.h),

              // Stats Row
              _buildStatsRow(),

              SizedBox(height: 24.h),

              // Divider
              Divider(color: Colors.white.withOpacity(0.05)),
              SizedBox(height: 24.h),

              // Escrow & Expiry
              _buildInfoRow("Escrow Service", "Active & Secured", valueColor: Colors.white),
              SizedBox(height: 16.h),
              _buildInfoRow("Offer Expires", _formattedTime, valueColor: const Color(0xFFFF6B6B)),

              SizedBox(height: 48.h),

              // Accept Button
              Container(
                width: double.infinity,
                height: 64.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B9BFF), Color(0xFF6B4BFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B9BFF).withOpacity(0.4),
                      blurRadius: 24.r,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Accept Offer",
                  style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.w900),
                ),
              ),

              SizedBox(height: 20.h),

              // Decline Text Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Center(
                  child: Text(
                    "Decline",
                    style: TextStyle(
                      color: const Color(0xFFFF6B6B),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeCards() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            // Your Item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("YOUR ITEM", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  SizedBox(height: 12.h),
                  Container(
                    height: 160.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161622),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                      image: const DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=1000&auto=format&fit=crop"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text("Chrono-Master V2", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4.h),
                  Text("Est. Value: \$12,400", style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            SizedBox(width: 60.w), // space for swap icon

            // The Offer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("THE OFFER", style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF8B9BFF), Color(0xFF6B4BFF)]),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text("THE OFFER", style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    height: 160.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161622),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFF8B9BFF).withOpacity(0.3)),
                      image: const DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1000&auto=format&fit=crop"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text("Nebula Sculpture #04", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4.h),
                  Text("+ \$2,500 Cash", style: TextStyle(color: const Color(0xFF8B9BFF), fontSize: 11.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),

        // Swap Icon centered between cards
        Positioned(
          child: Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8B9BFF).withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B9BFF).withOpacity(0.25),
                  blurRadius: 12.r,
                ),
              ],
            ),
            child: Icon(Icons.sync_alt_rounded, color: const Color(0xFF8B9BFF), size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildTraderInfo() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: const NetworkImage("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974&auto=format&fit=crop"),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14.r,
                  height: 14.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4BFF8B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF161622), width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Julian_D", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle),
                    ),
                    SizedBox(width: 6.w),
                    Text("Pro Trader • 4.8 Rating", style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, color: Colors.white38, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("TRADE VOLUME", "\$142.5K")),
        SizedBox(width: 16.w),
        Expanded(child: _buildStatCard("SUCCESS RATE", "99.2%")),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 13.sp, fontWeight: FontWeight.w700)),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
