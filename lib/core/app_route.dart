import 'package:get/get.dart';
import '../view/screens/onboarding/screen/onboarding_screen.dart';
import '../view/screens/auth/screen/login_screen.dart';
import '../view/screens/auth/screen/sign_up_screen.dart';
import '../view/screens/auth/screen/otp_screen.dart';
import '../view/screens/category/screen/category_screen.dart';
import '../view/screens/main/screen/main_screen.dart';
import '../view/screens/live_stream/screen/live_stream_screen.dart';
import '../view/screens/messages/screen/message_details_screen.dart';
import '../view/screens/purchases/screen/track_order/screen/track_order_screen.dart';
import '../view/screens/trade_details/screen/trade_details_screen.dart';
import '../view/screens/profile/screen/account_settings_screen.dart';
import '../view/screens/profile/screen/profile_information_screen.dart';
import '../view/screens/profile/screen/change_password_screen.dart';
import '../view/screens/profile/screen/user_preferences_screen.dart';

import '../view/screens/trade_market/screen/create_trade_screen.dart';
import '../view/screens/profile/screen/trader_profile_screen.dart';
import '../view/screens/purchases/screen/purchases_screen.dart';
import '../view/screens/my_trades/screen/my_trades_screen.dart';
import '../view/screens/trade_details/screen/make_offer_screen.dart';

class AppRoute {
  static const String onboarding = "/onboarding";
  static const String login = "/login";
  static const String signUp = "/signUp";
  static const String otp = "/otp";
  static const String category = "/category";
  static const String main = "/main";
  static const String trackOrder = "/trackOrder";
  static const String tradeDetails = "/trade_details";
  static const String messageDetails = "/message_details";
  static const String liveStream = "/live_stream";
  static const String createTrade = "/create_trade";
  static const String traderProfile = "/trader_profile";
  static const String purchases = "/purchases";
  static const String myTrades = "/my_trades";
  static const String makeOffer = "/make_offer";
  static const String accountSettings = "/account_settings";
  static const String profileInformation = "/profile_information";
  static const String changePassword = "/change_password";
  static const String userPreferences = "/user_preferences";

  static List<GetPage> routes = [
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    GetPage(name: otp, page: () => const OtpScreen()),
    GetPage(name: category, page: () => const CategoryScreen()),
    GetPage(name: main, page: () => const MainScreen()),
    GetPage(name: trackOrder, page: () => const TrackOrderScreen()),
    GetPage(name: tradeDetails, page: () => const TradeDetailsScreen()),
    GetPage(name: messageDetails, page: () => const MessageDetailsScreen()),
    GetPage(name: liveStream, page: () => const LiveStreamScreen()),
    GetPage(name: createTrade, page: () => const CreateTradeScreen()),
    GetPage(name: traderProfile, page: () => const TraderProfileScreen()),
    GetPage(name: purchases, page: () => const PurchasesScreen()),
    GetPage(name: myTrades, page: () => const MyTradesScreen()),
    GetPage(name: makeOffer, page: () => const MakeOfferScreen()),
    GetPage(name: accountSettings, page: () => const AccountSettingsScreen()),
    GetPage(name: profileInformation, page: () => const ProfileInformationScreen()),
    GetPage(name: changePassword, page: () => const ChangePasswordScreen()),
    GetPage(name: userPreferences, page: () => const UserPreferencesScreen()),
  ];
}
