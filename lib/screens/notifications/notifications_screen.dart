import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/notifications_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: const Text('Mark all read', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingWidget(message: 'Loading notifications...')
          : provider.notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 72, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('No notifications yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadNotifications(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, i) {
                      final n = provider.notifications[i];
                      final timeAgo = _timeAgo(n.createdAt);

                      return InkWell(
                        onTap: () {
                          if (!n.isRead) provider.markAsRead(n.id);
                        },
                        child: Container(
                          color: n.isRead ? null : AppColors.primary.withValues(alpha: 0.04),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(builder: (ctx) => Container(
                                width: ctx.iconBox, height: ctx.iconBox,
                                decoration: BoxDecoration(
                                  color: _iconColor(n.type).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_iconData(n.type), color: _iconColor(n.type), size: ctx.iconGlyph),
                              )),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n.title,
                                            style: TextStyle(
                                              fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (!n.isRead)
                                          Container(
                                            width: 8, height: 8,
                                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(n.body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                                    const SizedBox(height: 4),
                                    Text(timeAgo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _iconData(String? type) {
    switch (type) {
      case 'PACKAGE_VERIFIED': return Icons.check_circle_outline;
      case 'PACKAGE_REJECTED': return Icons.cancel_outlined;
      case 'DRIVER_ASSIGNED': return Icons.directions_car;
      case 'GROUP_UPDATE': return Icons.groups;
      default: return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String? type) {
    switch (type) {
      case 'PACKAGE_VERIFIED': return AppColors.success;
      case 'PACKAGE_REJECTED': return AppColors.error;
      case 'DRIVER_ASSIGNED': return AppColors.primary;
      case 'GROUP_UPDATE': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
