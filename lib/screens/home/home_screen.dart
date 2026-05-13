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

// ─────────────────────────────────────────────────────────────────────────────
// Supplemental card colors not in AppColors
// ─────────────────────────────────────────────────────────────────────────────
const _kEmerald = Color(0xFF065F46);
const _kRust = Color(0xFF7C2D12);
const _kSlate = Color(0xFF1E293B);

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────
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
    final nominations = context.watch<NominationProvider>();
    context.watch<GroupProvider>();
    final notifs = context.watch<NotificationsProvider>();
    final billing = context.watch<DriverBillingProvider>();

    final activeTrips = _todayTrips.where((t) => t.isActive).length;
    final netEarnings = billing.summary?.netEarnings ?? 0.0;
    final earningsStr = NumberFormat('#,##0').format(netEarnings);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _loadAll,
          displacement: 80,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Top bar ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _TopBar(
                  greeting: _greeting,
                  firstName: user?.firstName,
                  unreadCount: notifs.unreadCount,
                ),
              ),

              // ── Stat cards ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _StatCard(
                            label: 'Net Earnings',
                            sub: 'ETB · This month',
                            value: earningsStr,
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppColors.primaryDark,
                            onTap: () => context.push('/billing'),
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: "Today's Trips",
                            sub: activeTrips > 0
                                ? '$activeTrips active now'
                                : 'No active trips',
                            value: _todayTrips.length.toString(),
                            icon: Icons.directions_car_rounded,
                            color: AppColors.primaryLight,
                            onTap: () => context.go('/routes'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _StatCard(
                            label: 'Nominations',
                            sub: nominations.pendingCount > 0
                                ? 'Tap to respond'
                                : 'No pending',
                            value: nominations.pendingCount.toString(),
                            icon: Icons.pending_actions_rounded,
                            color:
                                nominations.pendingCount > 0 ? _kRust : _kSlate,
                            onTap: () => context.go('/nominations'),
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'Alerts',
                            sub: notifs.unreadCount > 0
                                ? 'Tap to read'
                                : 'All caught up',
                            value: notifs.unreadCount.toString(),
                            icon: Icons.notifications_rounded,
                            color: notifs.unreadCount > 0
                                ? AppColors.primary
                                : _kSlate,
                            onTap: () => context.push('/notifications'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Today's Routes ───────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                sliver: SliverToBoxAdapter(
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
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.route_rounded,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Today's Routes",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (_todayTrips.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_todayTrips.length}',
                                    style: const TextStyle(
                                      color: AppColors.textOnPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.go('/routes'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Trip list
                      if (_loadingTrips)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (_todayTrips.isEmpty)
                        const _EmptyCard(
                          icon: Icons.route_outlined,
                          message:
                              'No routes scheduled for today.\nCheck back after your groups are set up.',
                        )
                      else ...[
                        ..._todayTrips.take(2).map(
                              (trip) => _TripTile(
                                trip: trip,
                                onTap: () => context.go('/routes'),
                              ),
                            ),
                        if (_todayTrips.length > 2) ...[
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/routes'),
                              icon: const Icon(Icons.arrow_forward_rounded,
                                  size: 15),
                              label: Text(
                                'View ${_todayTrips.length - 2} more route'
                                '${_todayTrips.length - 2 > 1 ? 's' : ''}',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                    color: AppColors.border, width: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// _TopBar — uses AppColors.headerGradient, no overlap with cards below
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String greeting;
  final String? firstName;
  final int unreadCount;

  const _TopBar({
    required this.greeting,
    required this.firstName,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),

              // Greeting block
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
                        fontWeight: FontWeight.w600,
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

              // Notification bell
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 20),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gradientEnd,
                              width: 1.5,
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// _StatCard
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String sub;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.sub,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
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

// ─────────────────────────────────────────────────────────────────────────────
// _TripTile
// ─────────────────────────────────────────────────────────────────────────────
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
      statusLabel = 'Done';
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

    final tripIcon =
        trip.isToSchool ? Icons.school_rounded : Icons.home_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tripIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.routeLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trip.groupName} · ${trip.scheduledTime}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 10, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyCard
// ─────────────────────────────────────────────────────────────────────────────
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 32, color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
