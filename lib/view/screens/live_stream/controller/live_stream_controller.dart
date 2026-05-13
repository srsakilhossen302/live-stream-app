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
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-taking-photos-of-a-luxury-watch-33534-large.mp4',
      curator: '@jrehsales',
      viewers: '1.2K',
      title: 'Luxury Watch Auction',
      productTitle: 'Rolex Submariner',
      productPrice: '\$15,000',
      productImage: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=400&auto=format&fit=crop',
    ),
    LiveStreamModel(
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-close-up-of-a-person-opening-a-shoe-box-48197-large.mp4',
      curator: '@kicks_collector',
      viewers: '850',
      title: 'Rare Sneaker Unboxing',
      productTitle: 'Nike Dunk Low',
      productPrice: '\$180',
      productImage: 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=400&auto=format&fit=crop',
    ),
    LiveStreamModel(
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-man-holding-a-pair-of-sneakers-in-his-hands-48202-large.mp4',
      curator: '@hype_trader',
      viewers: '2.1K',
      title: 'Streetwear Steals',
      productTitle: 'Supreme Box Logo',
      productPrice: '\$450',
      productImage: 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=400&auto=format&fit=crop',
    ),
  ];

  // Simple list to track init status
  final List<bool> initialized = <bool>[];
  int currentIdx = 0;
  final List<VideoPlayerController> videoControllers = <VideoPlayerController>[];

  @override
  void onInit() {
    super.onInit();
    for (int i = 0; i < streams.length; i++) {
      initialized.add(false);
    }
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    for (int i = 0; i < streams.length; i++) {
      final vc = VideoPlayerController.networkUrl(Uri.parse(streams[i].videoUrl));
      videoControllers.add(vc);
      vc.initialize().then((_) {
        vc.setLooping(true);
        vc.setVolume(0);
        initialized[i] = true;
        if (i == currentIdx) {
          vc.play();
        }
        update(); // triggers GetBuilder rebuild
      });
    }
  }

  void onPageChanged(int index) {
    if (currentIdx < videoControllers.length) {
      videoControllers[currentIdx].pause();
    }
    currentIdx = index;
    if (index < videoControllers.length && initialized[index]) {
      videoControllers[index].play();
    }
    update();
  }

  @override
  void onClose() {
    for (var vc in videoControllers) {
      vc.dispose();
    }
    super.onClose();
  }
}
