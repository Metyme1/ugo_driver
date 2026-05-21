import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
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

  String _greeting(AppLocalizations l) {
    final h = DateTime.now().hour;
    if (h < 12) return l.goodMorning;
    if (h < 17) return l.goodAfternoon;
    return l.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              SliverToBoxAdapter(
                child: _TopBar(
                  greeting: _greeting(l),
                  firstName: user?.firstName,
                  unreadCount: notifs.unreadCount,
                  activeLabel: l.active,
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => context.push('/billing'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.netEarnings,
                                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('ETB $earningsStr',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500, letterSpacing: -0.5)),
                                const SizedBox(height: 4),
                                Text(l.thisMonthTapDetails,
                                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 26),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _MiniStat(
                        label: l.todaysTrips,
                        value: _todayTrips.length.toString(),
                        sub: activeTrips > 0 ? l.activeTripsCount(activeTrips) : l.noActiveTripsSub,
                        icon: Icons.directions_car_rounded,
                        color: AppColors.accent,
                        onTap: () => context.go('/routes'),
                      ),
                      const SizedBox(width: 10),
                      _MiniStat(
                        label: l.nominations,
                        value: nominations.pendingCount.toString(),
                        sub: nominations.pendingCount > 0 ? l.tapToRespond : l.noPending,
                        icon: Icons.pending_actions_rounded,
                        color: nominations.pendingCount > 0 ? AppColors.warning : AppColors.textSecondary,
                        onTap: () => context.go('/nominations'),
                      ),
                      const SizedBox(width: 10),
                      _MiniStat(
                        label: l.alerts,
                        value: notifs.unreadCount.toString(),
                        sub: notifs.unreadCount > 0 ? l.tapToRead : l.allClear,
                        icon: Icons.notifications_rounded,
                        color: notifs.unreadCount > 0 ? AppColors.error : AppColors.textSecondary,
                        onTap: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.route_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Text(l.todaysRoutes,
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              if (_todayTrips.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('${_todayTrips.length}',
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.go('/routes'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              textStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400),
                            ),
                            child: Text(l.viewAll),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_loadingTrips)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      else if (_todayTrips.isEmpty)
                        _EmptyCard(
                          icon: Icons.route_outlined,
                          message: l.noRoutesScheduledHome,
                        )
                      else ...[
                        ..._todayTrips.take(2).map((trip) => _TripTile(trip: trip, l: l, onTap: () => context.go('/routes'))),
                        if (_todayTrips.length > 2) ...[
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/routes'),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                              label: Text(
                                _todayTrips.length - 2 == 1
                                    ? l.viewMoreRoutes(_todayTrips.length - 2)
                                    : l.viewMoreRoutesPlural(_todayTrips.length - 2),
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _TopBar extends StatelessWidget {
  final String greeting;
  final String? firstName;
  final int unreadCount;
  final String activeLabel;
  const _TopBar({required this.greeting, required this.firstName, required this.unreadCount, required this.activeLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(greeting,
                          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w400)),
                        const SizedBox(width: 8),
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(activeLabel,
                          style: GoogleFonts.outfit(color: AppColors.accentLight, fontSize: 11, fontWeight: FontWeight.w400)),
                      ],
                    ),
                    Text(firstName ?? 'Driver',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500, height: 1.2)),
                    Text(DateFormat('EEE, MMM d').format(DateTime.now()),
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Stack(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0, top: 0,
                        child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryDark, width: 1.5),
                          ),
                          child: Center(
                            child: Text('$unreadCount',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500)),
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

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniStat({
    required this.label, required this.value, required this.sub,
    required this.icon, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 10),
              Text(value,
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1)),
              const SizedBox(height: 2),
              Text(label,
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
              const SizedBox(height: 1),
              Text(sub,
                style: GoogleFonts.outfit(fontSize: 10, color: color),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  final DriverDailyTrip trip;
  final AppLocalizations l;
  final VoidCallback onTap;
  const _TripTile({required this.trip, required this.l, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    if (trip.isCompleted) {
      statusColor = AppColors.success;
      statusLabel = l.statusDone;
      statusIcon = Icons.check_circle_rounded;
    } else if (trip.isActive) {
      statusColor = AppColors.warning;
      statusLabel = l.active;
      statusIcon = Icons.play_circle_rounded;
    } else {
      statusColor = AppColors.textHint;
      statusLabel = l.scheduled;
      statusIcon = Icons.schedule_rounded;
    }

    final tripIcon = trip.isToSchool ? Icons.school_rounded : Icons.home_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(tripIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.routeLabel,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('${trip.groupName} · ${trip.scheduledTime}',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 10, color: statusColor),
                  const SizedBox(width: 4),
                  Text(statusLabel,
                    style: GoogleFonts.outfit(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text(message,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.textSecondary, height: 1.6, fontSize: 13)),
        ],
      ),
    );
  }
}
