import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/daily_trip_model.dart';
import '../../services/api_service.dart';
import '../../services/trip_service.dart';
import '../../utils/responsive.dart';

/// Screen shown while the driver is actively running a route.
/// - Streams GPS location to the backend every 5 seconds.
/// - Lets the driver mark each student as picked up / dropped off.
/// - Has an "End Route" button to complete the trip.
class ActiveRouteScreen extends StatefulWidget {
  final String tripId;
  final String tripLabel;

  const ActiveRouteScreen({
    super.key,
    required this.tripId,
    required this.tripLabel,
  });

  @override
  State<ActiveRouteScreen> createState() => _ActiveRouteScreenState();
}

class _ActiveRouteScreenState extends State<ActiveRouteScreen> {
  final _service = DriverTripService(ApiService());

  List<StudentTripStatus> _students = [];
  bool _loadingStudents = true;
  bool _completing = false;

  Timer? _locationTimer;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _startLocationStream();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  // ── Location streaming ────────────────────────────────────────────────────

  void _startLocationStream() {
    _sendLocation(); // immediate first send
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _sendLocation(),
    );
  }

  Future<void> _sendLocation() async {
    debugPrint('[GPS] Requesting position…');
    final pos = await DriverTripService.getCurrentPosition();
    if (pos == null) {
      debugPrint('[GPS] ERROR: position is null (permission denied or GPS off)');
      if (mounted) setState(() => _locationError = 'Location permission denied');
      return;
    }
    debugPrint('[GPS] Got position: ${pos.latitude}, ${pos.longitude}');
    final sent = await _service.updateLocation(widget.tripId, pos.latitude, pos.longitude);
    debugPrint('[GPS] Backend update: ${sent ? "OK" : "FAILED"}');
    if (mounted) {
      setState(() => _locationError = sent ? null : 'Location update failed');
    }
  }

  // ── Students ──────────────────────────────────────────────────────────────

  Future<void> _loadStudents() async {
    setState(() => _loadingStudents = true);
    final students = await _service.getTripStudents(widget.tripId);
    if (!mounted) return;
    setState(() {
      _students = students;
      _loadingStudents = false;
    });
  }

  Future<void> _markPickup(StudentTripStatus s) async {
    try {
      await _service.pickupStudent(widget.tripId, s.childId);
      _loadStudents();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _markDropoff(StudentTripStatus s) async {
    try {
      await _service.dropoffStudent(widget.tripId, s.childId);
      _loadStudents();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Complete trip ─────────────────────────────────────────────────────────

  Future<void> _completeTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Route?'),
        content: const Text(
          'Mark this route as completed?\nParents will be notified that all students have been delivered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('End Route', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _completing = true);
    try {
      await _service.completeTrip(widget.tripId);
      if (!mounted) return;
      Navigator.pop(context); // return to route list
    } catch (e) {
      if (!mounted) return;
      setState(() => _completing = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pickedUp   = _students.where((s) => s.pickedUp).length;
    final droppedOff = _students.where((s) => s.droppedOff).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(widget.tripLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: 'Refresh students',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Status bar ─────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.people,
                  label: 'Total',
                  value: '${_students.length}',
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.directions_bus,
                  label: 'On board',
                  value: '$pickedUp',
                  color: AppColors.warning,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.check_circle,
                  label: 'Delivered',
                  value: '$droppedOff',
                  color: Colors.green.shade300,
                ),
                const Spacer(),
                // Live GPS indicator
                Row(
                  children: [
                    Icon(
                      _locationError != null ? Icons.location_off : Icons.location_on,
                      color: _locationError != null ? AppColors.error : Colors.greenAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _locationError != null ? 'No GPS' : 'Live',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Student list ───────────────────────────────────────────────
          if (_locationError != null)
            Container(
              color: AppColors.error.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _loadingStudents
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(
                        child: Text('No students for this trip.',
                            style: TextStyle(color: AppColors.textSecondary)),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(context.rv(10.0, 12.0, 16.0)),
                        itemCount: _students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _StudentCard(
                          status: _students[i],
                          onPickup:  () => _markPickup(_students[i]),
                          onDropoff: () => _markDropoff(_students[i]),
                        ),
                      ),
          ),

          // ── End route button ───────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(context.hPad),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completing ? null : _completeTrip,
                  icon: _completing
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.flag),
                  label: Text(_completing ? 'Ending Route…' : 'End Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Student card ──────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final StudentTripStatus status;
  final VoidCallback onPickup;
  final VoidCallback onDropoff;

  const _StudentCard({
    required this.status,
    required this.onPickup,
    required this.onDropoff,
  });

  @override
  Widget build(BuildContext context) {
    final picked  = status.pickedUp;
    final dropped = status.droppedOff;

    Color avatarColor;
    String statusText;
    if (dropped) {
      avatarColor = AppColors.success;
      statusText  = 'Delivered';
    } else if (picked) {
      avatarColor = AppColors.warning;
      statusText  = 'On board';
    } else {
      avatarColor = AppColors.textSecondary;
      statusText  = 'Waiting';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: avatarColor.withValues(alpha: 0.15),
              child: Icon(Icons.person, color: avatarColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.childName?.isNotEmpty == true ? status.childName! : 'Student',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  Row(
                    children: [
                      if (status.childGrade != null) ...[
                        Text(
                          'Grade ${status.childGrade}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const Text(' · ', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                      Text(statusText, style: TextStyle(color: avatarColor, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons
            if (!picked && !dropped)
              _ActionButton(
                label: 'Picked Up',
                icon: Icons.directions_bus,
                color: AppColors.primary,
                onTap: onPickup,
              )
            else if (picked && !dropped)
              _ActionButton(
                label: 'Drop Off',
                icon: Icons.place,
                color: AppColors.success,
                onTap: onDropoff,
              )
            else
              const Icon(Icons.check_circle, color: AppColors.success, size: 28),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
        ),
      );
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(value,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      );
}
