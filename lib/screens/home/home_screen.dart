import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/daily_trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nomination_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../services/api_service.dart';
import '../../services/trip_service.dart';
import '../../utils/responsive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DriverDailyTrip> _todayTrips = [];
  bool _loadingTrips = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    await Future.wait([
      context.read<NominationProvider>().loadNominations(),
      context.read<GroupProvider>().loadMyGroups(),
      context.read<NotificationsProvider>().loadNotifications(),
      _loadTrips(),
    ]);
  }

  Future<void> _loadTrips() async {
    if (!mounted) return;
    setState(() => _loadingTrips = true);
    try {
      final trips = await DriverTripService(ApiService()).getTodayTrips();
      if (mounted) setState(() => _todayTrips = trips);
    } catch (_) {
      if (mounted) setState(() => _todayTrips = []);
    } finally {
      if (mounted) setState(() => _loadingTrips = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final nominationProvider = context.watch<NominationProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final notifProvider = context.watch<NotificationsProvider>();

    final activeTrips = _todayTrips.where((t) => t.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.firstName ?? 'Driver'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => context.push('/notifications'),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${notifProvider.unreadCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats grid
              Row(
                children: [
                  _StatCard(
                    label: 'Active Groups',
                    value: groupProvider.groups.length.toString(),
                    icon: Icons.groups,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: context.gap),
                  _StatCard(
                    label: "Today's Trips",
                    value: _todayTrips.length.toString(),
                    icon: Icons.route,
                    color: activeTrips > 0 ? AppColors.success : AppColors.textSecondary,
                  ),
                ],
              ),
              SizedBox(height: context.gap),
              Row(
                children: [
                  _StatCard(
                    label: 'Pending Nominations',
                    value: nominationProvider.pendingCount.toString(),
                    icon: Icons.pending_actions,
                    color: nominationProvider.pendingCount > 0 ? AppColors.warning : AppColors.textSecondary,
                  ),
                  SizedBox(width: context.gap),
                  _StatCard(
                    label: 'Unread Alerts',
                    value: notifProvider.unreadCount.toString(),
                    icon: Icons.notifications_outlined,
                    color: notifProvider.unreadCount > 0 ? AppColors.info : AppColors.textSecondary,
                  ),
                ],
              ),
              SizedBox(height: context.rv(16.0, 20.0, 28.0)),

              // Today's Routes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Routes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.fsTitle, color: AppColors.textPrimary)),
                  TextButton(onPressed: () => context.go('/routes'), child: const Text('View All')),
                ],
              ),
              SizedBox(height: context.gap),
              if (_loadingTrips)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else if (_todayTrips.isEmpty)
                const _EmptyCard(
                  icon: Icons.route,
                  message: 'No routes scheduled for today.\nCheck back after your groups are set up.',
                )
              else
                ..._todayTrips.take(3).map((trip) => _TripTile(
                      trip: trip,
                      onTap: () => context.go('/routes'),
                    )),
              SizedBox(height: context.rv(16.0, 20.0, 28.0)),

              // Pending nominations banner
              if (nominationProvider.pendingCount > 0) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.hPad),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${nominationProvider.pendingCount} pending nomination${nominationProvider.pendingCount > 1 ? 's' : ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Groups are waiting for your response',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: context.fsBody),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/nominations'),
                        child: const Text('View'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.rv(12.0, 16.0, 20.0)),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Trip tile ─────────────────────────────────────────────────────────────────

class _TripTile extends StatelessWidget {
  final DriverDailyTrip trip;
  final VoidCallback onTap;
  const _TripTile({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    if (trip.isCompleted) {
      statusColor = AppColors.success;
      statusLabel = 'Completed';
      statusIcon = Icons.check_circle;
    } else if (trip.isActive) {
      statusColor = AppColors.warning;
      statusLabel = 'Active';
      statusIcon = Icons.play_circle;
    } else {
      statusColor = AppColors.textSecondary;
      statusLabel = 'Scheduled';
      statusIcon = Icons.schedule;
    }

    final iconBox = context.iconBox;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(context.rv(12.0, 14.0, 18.0)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                trip.isToSchool ? Icons.school : Icons.home,
                color: statusColor,
                size: context.iconGlyph,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.routeLabel,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.fsBody),
                  ),
                  Text(
                    '${trip.groupName} · ${trip.scheduledTime}',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: context.fsCaption),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(fontSize: context.fsCaption, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final iconBox = context.rv(36.0, 40.0, 48.0);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(context.rv(12.0, 14.0, 18.0)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: context.rv(18.0, 20.0, 24.0)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontSize: context.rv(18.0, 20.0, 24.0), fontWeight: FontWeight.bold, color: color)),
                  Text(label, style: TextStyle(fontSize: context.fsCaption, color: AppColors.textSecondary, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty card ────────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rv(20.0, 24.0, 32.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: context.rv(40.0, 48.0, 56.0), color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: context.fsBody),
          ),
        ],
      ),
    );
  }
}
