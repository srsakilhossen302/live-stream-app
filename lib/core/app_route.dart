import 'package:get/get.dart';
import '../view/screens/onboarding/screen/onboarding_screen.dart';
import '../view/screens/auth/screen/login_screen.dart';
import '../view/screens/category/screen/category_screen.dart';
import '../view/screens/main/screen/main_screen.dart';
import '../view/screens/messages/screen/message_details_screen.dart';
import '../view/screens/purchases/screen/track_order/screen/track_order_screen.dart';
import '../view/screens/trade_details/screen/trade_details_screen.dart';

class AppRoute {
  static const String onboarding = "/onboarding";
  static const String login = "/login";
  static const String category = "/category";
  static const String main = "/main";
  static const String trackOrder = "/trackOrder";
  static const String tradeDetails = "/trade_details";
  static const String messageDetails = "/message_details";

  static List<GetPage> routes = [
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: category, page: () => const CategoryScreen()),
    GetPage(name: main, page: () => const MainScreen()),
    GetPage(name: trackOrder, page: () => const TrackOrderScreen()),
    GetPage(name: tradeDetails, page: () => const TradeDetailsScreen()),
    GetPage(name: messageDetails, page: () => const MessageDetailsScreen()),
  ];
}
