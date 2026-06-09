class ApiUrl {
  static const String baseUrl = "http://10.10.7.50:5007/api/v1";

  // Auth
  static const String login = "/auth/login";
  static const String signUp = "/auth/signup";
  static const String verifyAccount = "/auth/verify-account";
  static const String forgotPassword = "/auth/forget-password";
  static const String resetPassword = "/auth/reset-password";
  static const String updateProfile = "/users/profile";
  static const String resendOtp = "/auth/resend-otp";
}
