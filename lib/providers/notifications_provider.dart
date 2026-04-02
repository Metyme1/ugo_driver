import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsService _service = NotificationsService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    final response = await _service.getNotifications();
    _isLoading = false;
    if (response.success) _notifications = response.data ?? [];
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifications[idx] = NotificationModel(
        id: _notifications[idx].id,
        title: _notifications[idx].title,
        body: _notifications[idx].body,
        isRead: true,
        type: _notifications[idx].type,
        data: _notifications[idx].data,
        createdAt: _notifications[idx].createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
    await loadNotifications();
  }
}
