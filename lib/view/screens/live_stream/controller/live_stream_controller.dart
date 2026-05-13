import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class LiveStreamController extends GetxController {
  final List<String> videoUrls = [
    'https://assets.mixkit.co/videos/preview/mixkit-taking-photos-of-a-luxury-watch-33534-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-close-up-of-a-person-opening-a-shoe-box-48197-large.mp4',
    'https://assets.mixkit.co/videos/preview/mixkit-man-holding-a-pair-of-sneakers-in-his-hands-48202-large.mp4',
  ];

  var controllers = <VideoPlayerController>[].obs;
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    for (var url in videoUrls) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      controller.setLooping(true);
      controllers.add(controller);
    }
    if (controllers.isNotEmpty) {
      controllers[0].play();
    }
  }

  void onPageChanged(int index) {
    controllers[currentIndex.value].pause();
    currentIndex.value = index;
    controllers[currentIndex.value].play();
  }

  @override
  void onClose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.onClose();
  }
}
