import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/daily_trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nomination_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/driver_billing_provider.dart';
import '../../services/api_service.dart';
import '../../services/trip_service.dart';

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
      context.read<DriverBillingProvider>().loadSummary(),
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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final nominationProvider = context.watch<NominationProvider>();
    context.watch<GroupProvider>();
    final notifProvider = context.watch<NotificationsProvider>();
    final billingProvider = context.watch<DriverBillingProvider>();

    final activeTrips = _todayTrips.where((t) => t.isActive).length;
    final netEarnings = billingProvider.summary?.netEarnings ?? 0.0;
    final earningsStr = NumberFormat('#,##0').format(netEarnings);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _loadAll,
          displacement: 100,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Gradient header ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HomeHeader(
                  greeting: _greeting,
                  firstName: user?.firstName,
                  unreadCount: notifProvider.unreadCount,
                ),
              ),

              // ── Stat cards ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _QuickStatCard(
                              label: 'Net Earnings',
                              sublabel: 'ETB · This month',
                              value: earningsStr,
                              icon: Icons.account_balance_wallet_rounded,
                              gradientColors: const [Color(0xFF0D47A1), Color(0xFF1E88E5)],
                              onTap: () => context.push('/billing'),
                            ),
                            const SizedBox(width: 12),
                            _QuickStatCard(
                              label: "Today's Trips",
                              sublabel: activeTrips > 0 ? '$activeTrips active now' : 'No active trips',
                              value: _todayTrips.length.toString(),
                              icon: Icons.directions_car_rounded,
                              gradientColors: const [Color(0xFF059669), Color(0xFF34D399)],
                              onTap: () => context.go('/routes'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _QuickStatCard(
                              label: 'Nominations',
                              sublabel: nominationProvider.pendingCount > 0 ? 'Tap to respond' : 'No pending',
                              value: nominationProvider.pendingCount.toString(),
                              icon: Icons.pending_actions_rounded,
                              gradientColors: nominationProvider.pendingCount > 0
                                  ? const [Color(0xFFEA580C), Color(0xFFFB923C)]
                                  : const [Color(0xFF475569), Color(0xFF64748B)],
                              onTap: () => context.go('/nominations'),
                            ),
                            const SizedBox(width: 12),
                            _QuickStatCard(
                              label: 'Alerts',
                              sublabel: notifProvider.unreadCount > 0 ? 'Tap to read' : 'All caught up',
                              value: notifProvider.unreadCount.toString(),
                              icon: Icons.notifications_rounded,
                              gradientColors: notifProvider.unreadCount > 0
                                  ? const [Color(0xFF0C4A6E), Color(0xFF0284C7)]
                                  : const [Color(0xFF475569), Color(0xFF64748B)],
                              onTap: () => context.push('/notifications'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Today's Routes ────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.route_rounded, color: AppColors.primary, size: 16),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Today's Routes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (_todayTrips.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_todayTrips.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            TextButton(
                              onPressed: () => context.go('/routes'),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Routes list
                        if (_loadingTrips)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(28),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_todayTrips.isEmpty)
                          const _EmptyCard(
                            icon: Icons.route_outlined,
                            message: 'No routes scheduled for today.\nCheck back after your groups are set up.',
                          )
                        else ...[
                          ..._todayTrips.take(2).map(
                                (trip) => _TripTile(
                                  trip: trip,
                                  onTap: () => context.go('/routes'),
                                ),
                              ),
                          if (_todayTrips.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: () => context.go('/routes'),
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                  label: Text(
                                    'View ${_todayTrips.length - 2} more route${_todayTrips.length - 2 > 1 ? 's' : ''}',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Home header ───────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final String greeting;
  final String? firstName;
  final int unreadCount;

  const _HomeHeader({
    required this.greeting,
    required this.firstName,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              // Greeting + name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Active',
                          style: TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      firstName ?? 'Driver',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      DateFormat('EEE, MMM d').format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification button
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick stat card ───────────────────────────────────────────────────────────

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _QuickStatCard({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.55),
                    size: 11,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
      statusIcon = Icons.check_circle_rounded;
    } else if (trip.isActive) {
      statusColor = AppColors.warning;
      statusLabel = 'Active';
      statusIcon = Icons.play_circle_rounded;
    } else {
      statusColor = AppColors.textSecondary;
      statusLabel = 'Scheduled';
      statusIcon = Icons.schedule_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                trip.isToSchool ? Icons.school_rounded : Icons.home_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.routeLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trip.groupName} · ${trip.scheduledTime}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 11, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
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
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
