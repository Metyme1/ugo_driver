class ApiConfig {
  static const String baseUrl = 'http://192.168.1.9:3001/api';

  static const int connectionTimeout = 60000;
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 60000;

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String resendOtp = '/auth/resend-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // Profile
  static const String updateProfile = '/users/profile';
  static const String fcmToken = '/users/fcm-token';

  // Driver-specific
  static const String myNominations = '/driver/nominations';
  static String nominationDetail(String groupId) =>
      '/driver/nominations/$groupId';
  static const String myGroups = '/driver/groups';
  static const String scanQr = '/ride-packages/scan';
  static const String scanConfirm = '/ride-packages/scan/confirm';

  // Notifications
  static const String notifications = '/notifications';

  // Driver billing
  static const String billingSummary = '/driver/billing/summary';
  static const String billingEarnings = '/driver/billing/earnings';
  static const String billingPlatformSubs =
      '/driver/billing/platform-subscriptions';
}
