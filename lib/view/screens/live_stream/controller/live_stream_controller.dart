import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class LiveStreamModel {
  final String videoUrl;
  final String curator;
  final String viewers;
  final String title;
  final String productTitle;
  final String productPrice;
  final String productImage;

  LiveStreamModel({
    required this.videoUrl,
    required this.curator,
    required this.viewers,
    required this.title,
    required this.productTitle,
    required this.productPrice,
    required this.productImage,
  });
}

class LiveStreamController extends GetxController {
  final List<LiveStreamModel> streams = [
    LiveStreamModel(
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      curator: '@jrehsales',
      viewers: '1.2K',
      title: 'Luxury Watch Auction',
      productTitle: 'Rolex Submariner',
      productPrice: '\$15,000',
      productImage: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=400&auto=format&fit=crop',
    ),
    LiveStreamModel(
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      curator: '@kicks_collector',
      viewers: '850',
      title: 'Rare Sneaker Unboxing',
      productTitle: 'Nike Dunk Low',
      productPrice: '\$180',
      productImage: 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=400&auto=format&fit=crop',
    ),
    LiveStreamModel(
      videoUrl: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
      curator: '@hype_trader',
      viewers: '2.1K',
      title: 'Streetwear Steals',
      productTitle: 'Supreme Box Logo',
      productPrice: '\$450',
      productImage: 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=400&auto=format&fit=crop',
    ),
  ];

  // Track initialization status
  final RxList<bool> videoReady = <bool>[].obs;
  int currentIdx = 0;
  final RxList<VideoPlayerController?> videoControllers = <VideoPlayerController?>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize lists with correct length
    for (int i = 0; i < streams.length; i++) {
      videoReady.add(false);
      videoControllers.add(null);
    }
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    for (int i = 0; i < streams.length; i++) {
      try {
        debugPrint('🎬 Initializing Video $i: ${streams[i].videoUrl}');
        
        final vc = VideoPlayerController.networkUrl(
          Uri.parse(streams[i].videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        
        videoControllers[i] = vc;
        
        await vc.initialize().timeout(const Duration(seconds: 15), onTimeout: () {
          throw 'Connection timeout for video $i';
        });

        vc.setLooping(true);
        vc.setVolume(1.0);
        videoReady[i] = true;

        if (i == currentIdx) {
          await vc.play();
        }
        
        update();
        debugPrint('✅ Video $i initialized successfully');
      } catch (e) {
        debugPrint('❌ Video $i failed to initialize: $e');
        videoReady[i] = false;
        // Keep the controller as null or handle error state
        update();
      }
      // Small delay between initializations to avoid overwhelming the network
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void onPageChanged(int index) {
    // Pause previous video
    if (currentIdx < videoControllers.length) {
      final oldController = videoControllers[currentIdx];
      if (oldController != null && videoReady[currentIdx]) {
        oldController.pause();
      }
    }

    currentIdx = index;

    // Play current video
    if (index < videoControllers.length) {
      final newController = videoControllers[index];
      if (newController != null && videoReady[index]) {
        newController.play();
      } else if (newController != null && !videoReady[index]) {
        // If not ready, try to re-initialize or wait
        debugPrint('⏳ Video $index is not ready yet');
      }
    }
    update();
  }

  @override
  void onClose() {
    for (var vc in videoControllers) {
      vc?.dispose();
    }
    super.onClose();
  }
}
