import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/daily_trip_model.dart';
import '../../services/api_service.dart';
import '../../services/trip_service.dart';
import '../../utils/responsive.dart';
import 'active_route_screen.dart';

class RouteManagementScreen extends StatefulWidget {
  const RouteManagementScreen({super.key});

  @override
  State<RouteManagementScreen> createState() => _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
  final _service = DriverTripService(ApiService());
  List<DriverDailyTrip> _trips = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final trips = await _service.getTodayTrips();
      setState(() { _trips = trips; _loading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _startTrip(DriverDailyTrip trip) async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.startRouteConfirm, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        content: Text(l.startRouteConfirmMsg(trip.routeLabel), style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel, style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.startRoute,
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _service.startTrip(trip.id);
      if (!mounted) return;
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => ActiveRouteScreen(tripId: trip.id, tripLabel: trip.routeLabel),
        ),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', ''), style: GoogleFonts.outfit()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.todaysRoutes, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 18)),
        actions: [
          IconButton(
            icon: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
            ),
            onPressed: _load,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load, l: l)
              : _trips.isEmpty
                  ? _EmptyView(onRetry: _load, l: l)
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(context.hPad, 16, context.hPad, 32),
                        itemCount: _trips.length,
                        itemBuilder: (_, i) => _TripCard(
                          trip: _trips[i],
                          l: l,
                          onStart: () => _startTrip(_trips[i]),
                          onResume: () => Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => ActiveRouteScreen(
                                tripId: _trips[i].id,
                                tripLabel: _trips[i].routeLabel,
                              ),
                            ),
                          ).then((_) => _load()),
                        ),
                      ),
                    ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final DriverDailyTrip trip;
  final AppLocalizations l;
  final VoidCallback onStart;
  final VoidCallback onResume;

  const _TripCard({required this.trip, required this.l, required this.onStart, required this.onResume});

  Color get _statusColor {
    switch (trip.status) {
      case 'started':
      case 'in_progress': return AppColors.accent;
      case 'completed':   return AppColors.primary;
      case 'cancelled':   return AppColors.error;
      default:            return AppColors.textSecondary;
    }
  }

  String _statusLabel(AppLocalizations l) {
    switch (trip.status) {
      case 'scheduled':   return l.scheduled;
      case 'started':
      case 'in_progress': return l.active;
      case 'completed':   return l.statusDone;
      default:            return trip.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: context.iconBox,
                      height: context.iconBox,
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        trip.isToSchool ? Icons.school_rounded : Icons.home_rounded,
                        color: _statusColor,
                        size: context.iconGlyph,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trip.routeLabel,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(trip.groupName,
                            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(_statusLabel(l),
                        style: GoogleFonts.outfit(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.divider),
                const SizedBox(height: 14),

                Row(
                  children: [
                    _Stat(icon: Icons.schedule_rounded, label: l.time, value: trip.scheduledTime),
                    if (trip.isActive || trip.isCompleted) ...[
                      const SizedBox(width: 8),
                      _Stat(icon: Icons.people_rounded, label: l.students, value: '${trip.studentCount}'),
                      const SizedBox(width: 8),
                      _Stat(
                        icon: Icons.check_circle_outline_rounded,
                        label: l.pickedUpStat,
                        value: '${trip.pickedUpCount}/${trip.studentCount}',
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                      _Stat(icon: Icons.people_rounded, label: l.students, value: '${trip.studentCount}'),
                    ],
                  ],
                ),

                const SizedBox(height: 14),
                _buildActionButton(l),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(AppLocalizations l) {
    if (trip.isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Text(l.completed, style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      );
    }

    if (trip.isActive) {
      return GestureDetector(
        onTap: onResume,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(l.resumeRoute, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (trip.isScheduled) {
      return GestureDetector(
        onTap: onStart,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(l.startRoute, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textHint),
          const SizedBox(width: 5),
          Flexible(
            child: Text('$label: $value',
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final AppLocalizations l;
  const _ErrorView({required this.message, required this.onRetry, required this.l});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
              child: Text(l.retry, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  final AppLocalizations l;
  const _EmptyView({required this.onRetry, required this.l});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_bus_outlined, color: AppColors.primary, size: 44),
          ),
          const SizedBox(height: 20),
          Text(l.noRoutesToday,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(l.noRoutesMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(l.refresh, style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
