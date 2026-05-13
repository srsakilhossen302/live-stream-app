import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../home/controller/home_controller.dart';

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
      productImage: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=1000&auto=format&fit=crop',
    ),
    LiveStreamModel(
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-close-up-of-a-person-opening-a-shoe-box-48197-large.mp4',
      curator: '@kicks_collector',
      viewers: '850',
      title: 'Rare Sneaker Unboxing',
      productTitle: 'Nike Dunk Low',
      productPrice: '\$180',
      productImage: 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=1000&auto=format&fit=crop',
    ),
    LiveStreamModel(
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-man-holding-a-pair-of-sneakers-in-his-hands-48202-large.mp4',
      curator: '@hype_trader',
      viewers: '2.1K',
      title: 'Streetwear Steals',
      productTitle: 'Supreme Box Logo',
      productPrice: '\$450',
      productImage: 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=1000&auto=format&fit=crop',
    ),
  ];

  var controllers = <VideoPlayerController>[].obs;
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    // If we came from Home with arguments, we can prepend it or replace the first one
    if (Get.arguments != null && Get.arguments is LiveItemModel) {
      final LiveItemModel item = Get.arguments;
      // You might want to match a video to the item, for now just use the first video slot
    }

    for (var stream in streams) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(stream.videoUrl));
      controllers.add(controller);
      controller.initialize().then((_) {
        controller.setLooping(true);
        if (controllers.indexOf(controller) == currentIndex.value) {
          controller.play();
        }
        update(); // Refresh UI when initialized
      });
    }
  }

  void onPageChanged(int index) {
    if (currentIndex.value < controllers.length) {
      controllers[currentIndex.value].pause();
    }
    currentIndex.value = index;
    if (index < controllers.length) {
      controllers[index].play();
    }
  }

  @override
  void onClose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
