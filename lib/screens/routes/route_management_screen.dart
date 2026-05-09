import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Start Route?'),
        content: Text('Start the "${trip.routeLabel}" route?\n\nParents will be notified immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Start Route', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _service.startTrip(trip.id);
      if (!mounted) return;

      // Navigate to active route screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveRouteScreen(tripId: trip.id, tripLabel: trip.routeLabel),
        ),
      );
      _load(); // Refresh after returning
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        title: const Text("Today's Routes"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : _trips.isEmpty
                  ? _EmptyView(onRetry: _load)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: EdgeInsets.all(context.hPad),
                        itemCount: _trips.length,
                        itemBuilder: (_, i) => _TripCard(
                          trip: _trips[i],
                          onStart: () => _startTrip(_trips[i]),
                          onResume: () => Navigator.push(
                            context,
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

// ── Trip card ─────────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
  final DriverDailyTrip trip;
  final VoidCallback onStart;
  final VoidCallback onResume;

  const _TripCard({required this.trip, required this.onStart, required this.onResume});

  Color get _statusColor {
    switch (trip.status) {
      case 'started':
      case 'in_progress': return AppColors.success;
      case 'completed':   return AppColors.primary;
      case 'cancelled':   return AppColors.error;
      default:            return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Builder(builder: (context) => Container(
                  width: context.iconBox,
                  height: context.iconBox,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    trip.isToSchool ? Icons.school : Icons.home,
                    color: AppColors.primary,
                    size: context.iconGlyph,
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.routeLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(trip.groupName,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                _StatusBadge(status: trip.status, color: _statusColor),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Expanded(child: _Stat(icon: Icons.schedule, label: 'Time', value: trip.scheduledTime)),
                if (trip.isActive || trip.isCompleted) ...[
                  const SizedBox(width: 8),
                  Expanded(child: _Stat(icon: Icons.people, label: 'Students', value: '${trip.studentCount}')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Stat(
                      icon: Icons.check_circle_outline,
                      label: 'Picked up',
                      value: '${trip.pickedUpCount}/${trip.studentCount}',
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Expanded(child: _Stat(icon: Icons.people, label: 'Students', value: '${trip.studentCount}')),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Action button
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (trip.isCompleted) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle, color: AppColors.success),
        label: const Text('Completed', style: TextStyle(color: AppColors.success)),
      );
    }

    if (trip.isActive) {
      return ElevatedButton.icon(
        onPressed: onResume,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Resume Route'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    if (trip.isScheduled) {
      return ElevatedButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.directions_bus),
        label: const Text('Start Route'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  String get _label {
    switch (status) {
      case 'scheduled':   return 'Scheduled';
      case 'started':
      case 'in_progress': return 'Active';
      case 'completed':   return 'Done';
      default:            return status;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      _label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 14, color: AppColors.textHint),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          '$label: $value',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyView({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_bus_outlined, color: AppColors.textHint, size: 64),
          const SizedBox(height: 12),
          const Text('No routes today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'You have no assigned groups or no routes scheduled for today.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    ),
  );
}
