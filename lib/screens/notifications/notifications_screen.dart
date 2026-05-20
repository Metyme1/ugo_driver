import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/notifications_provider.dart';
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

  Future<void> _confirmClearAll(NotificationsProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear All', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        content: Text('Delete all notifications? This cannot be undone.',
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear All',
              style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await provider.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Notifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 18)),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text('Mark all read',
                style: GoogleFonts.outfit(
                  color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          if (provider.notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (v) { if (v == 'clear') _confirmClearAll(provider); },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 18),
                      const SizedBox(width: 10),
                      Text('Clear all',
                        style: GoogleFonts.outfit(color: AppColors.error, fontSize: 14)),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingWidget(message: 'Loading notifications...')
          : provider.notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: () => provider.loadNotifications(),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final n = provider.notifications[i];
                      return _NotificationTile(
                        notification: n,
                        onTap: () { if (!n.isRead) provider.markAsRead(n.id); },
                        onDelete: () => provider.deleteNotification(n.id),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('All caught up!',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('No notifications yet',
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Per-item tile with swipe-to-delete ───────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final dynamic notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final color = _iconColor(n.type);

    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
            const SizedBox(height: 4),
            Text('Delete', style: GoogleFonts.outfit(color: AppColors.error, fontSize: 11)),
          ],
        ),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: n.isRead
                ? Colors.white
                : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: n.isRead
                  ? AppColors.border.withValues(alpha: 0.5)
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: n.isRead ? 0.03 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_iconData(n.type), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            )),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.body,
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                    const SizedBox(height: 6),
                    Text(_timeAgo(n.createdAt),
                      style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconData(String? type) {
    switch (type) {
      case 'PACKAGE_VERIFIED': return Icons.check_circle_outline_rounded;
      case 'PACKAGE_REJECTED': return Icons.cancel_outlined;
      case 'DRIVER_ASSIGNED':  return Icons.directions_car_rounded;
      case 'GROUP_UPDATE':     return Icons.groups_rounded;
      default:                 return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String? type) {
    switch (type) {
      case 'PACKAGE_VERIFIED': return AppColors.success;
      case 'PACKAGE_REJECTED': return AppColors.error;
      case 'DRIVER_ASSIGNED':  return AppColors.primary;
      case 'GROUP_UPDATE':     return AppColors.warning;
      default:                 return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}
