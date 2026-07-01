class ApiUrl {
  static const String baseUrl = "http://10.10.26.173:5007/api/v1";
  static const String imageBaseUrl = "http://10.10.26.173:5007";

  // Auth
  static const String login = "/auth/login";
  static const String signUp = "/auth/signup";
  static const String verifyAccount = "/auth/verify-account";
  static const String forgotPassword = "/auth/forget-password";
  static const String resetPassword = "/auth/reset-password";
  static const String updateProfile = "/users/profile";
  static const String resendOtp = "/auth/resend-otp";

  // User
  static const String profile = "/users/profile";

  // Products
  static const String products = "/products";

  // Notifications
  static const String myNotifications = "/notifications/my";

  // Orders
  static const String userOrders = "/orders/user";

  // Trades
  static const String tradeOffers = "/trades/offers";
}
