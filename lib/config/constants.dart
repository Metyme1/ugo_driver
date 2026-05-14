class AppConstants {
  static const String accessTokenKey = 'driver_access_token';
  static const String refreshTokenKey = 'driver_refresh_token';
  static const String phonePrefix = '+251';
  static const String appName = 'UGO Driver';

  // Must match QR_SECRET env var on backend
  static const String qrSecret = 'ugo-qr-secret-change-in-prod';
  static const String offlineQueueKey = 'offline_scan_queue';
}
