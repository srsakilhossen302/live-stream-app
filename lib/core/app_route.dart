import 'package:get/get.dart';
import '../view/screens/onboarding/screen/onboarding_screen.dart';
import '../view/screens/auth/screen/login_screen.dart';
import '../view/screens/category/screen/category_screen.dart';
import '../view/screens/home/screen/home_screen.dart';

class AppRoute {
  static const String onboarding = "/onboarding";
  static const String login = "/login";
  static const String category = "/category";
  static const String home = "/home";

  static List<GetPage> routes = [
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: category, page: () => const CategoryScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
  ];
}
