class ApiConfig {
  static const String baseUrl = 'http://10.97.236.184:3001/api';

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
  static const String myGroups = '/groups/my';
  static const String scanQr = '/ride-packages/scan';

  // Notifications
  static const String notifications = '/notifications';
}
