import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class FcmService {
  static final FcmService instance = FcmService._internal();
  FcmService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _messaging.requestPermission();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> uploadToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await ApiService().post(ApiConfig.fcmToken, data: {'fcm_token': token});
      }
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ugo_driver_channel',
          'UGO Driver Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigation handled by app router listening to notification data
  }
}
