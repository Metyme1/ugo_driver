import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/daily_trip_model.dart';
import '../../services/api_service.dart';
import '../../services/trip_service.dart';
import '../../utils/responsive.dart';

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

  StreamSubscription<Position>? _positionSub;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _startLocationStream();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  void _startLocationStream() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (!mounted) return;
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      final l = AppLocalizations.of(context);
      setState(() => _locationError = l?.locationPermissionDenied ?? 'Location permission denied');
      return;
    }
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      _onPosition,
      onError: (_) {
        if (mounted) setState(() => _locationError = 'GPS unavailable');
      },
    );
  }

  Future<void> _onPosition(Position pos) async {
    final sent = await _service.updateLocation(widget.tripId, pos.latitude, pos.longitude);
    if (mounted) {
      final l = AppLocalizations.of(context);
      setState(() => _locationError = sent ? null : (l?.locationUpdateFailed ?? 'Location update failed'));
    }
  }

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

  Future<void> _completeTrip() async {
    final l = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l.endRouteConfirm),
        content: Text(l.endRouteMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l.endRoute, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _completing = true);
    try {
      await _service.completeTrip(widget.tripId);
      if (!mounted) return;
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pickedUp   = _students.where((s) => s.pickedUp).length;
    final droppedOff = _students.where((s) => s.droppedOff).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.tripLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/scan'),
            tooltip: l.scanPassengerQr,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: l.refreshStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _StatChip(icon: Icons.people, label: l.total, value: '${_students.length}'),
                const SizedBox(width: 12),
                _StatChip(icon: Icons.directions_bus, label: l.onBoard, value: '$pickedUp', color: AppColors.warning),
                const SizedBox(width: 12),
                _StatChip(icon: Icons.check_circle, label: l.delivered, value: '$droppedOff', color: Colors.green.shade300),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      _locationError != null ? Icons.location_off : Icons.location_on,
                      color: _locationError != null ? AppColors.error : Colors.greenAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _locationError != null ? l.noGps : l.live,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_locationError != null)
            Container(
              color: AppColors.error.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_locationError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _loadingStudents
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? Center(child: Text(l.noStudentsForTrip, style: const TextStyle(color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: EdgeInsets.all(context.rv(10.0, 12.0, 16.0)),
                        itemCount: _students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _StudentCard(
                          status: _students[i],
                          l: l,
                          onPickup:  () => _markPickup(_students[i]),
                          onDropoff: () => _markDropoff(_students[i]),
                        ),
                      ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(context.hPad),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completing ? null : _completeTrip,
                  icon: _completing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.flag),
                  label: Text(_completing ? l.endingRoute : l.endRoute),
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

class _StudentCard extends StatelessWidget {
  final StudentTripStatus status;
  final AppLocalizations l;
  final VoidCallback onPickup;
  final VoidCallback onDropoff;

  const _StudentCard({required this.status, required this.l, required this.onPickup, required this.onDropoff});

  @override
  Widget build(BuildContext context) {
    final picked  = status.pickedUp;
    final dropped = status.droppedOff;

    Color avatarColor;
    String statusText;
    if (dropped) {
      avatarColor = AppColors.success;
      statusText  = l.delivered;
    } else if (picked) {
      avatarColor = AppColors.warning;
      statusText  = l.onBoard;
    } else {
      avatarColor = AppColors.textSecondary;
      statusText  = l.waiting;
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
                    status.childName?.isNotEmpty == true ? status.childName! : l.student,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  Row(
                    children: [
                      if (status.childGrade != null) ...[
                        Text(l.gradeLabel(status.childGrade!),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        const Text(' · ', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                      Text(statusText, style: TextStyle(color: avatarColor, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            if (!picked && !dropped)
              _ActionButton(label: l.pickedUpAction, icon: Icons.directions_bus, color: AppColors.primary, onTap: onPickup)
            else if (picked && !dropped)
              _ActionButton(label: l.dropOff, icon: Icons.place, color: AppColors.success, onTap: onDropoff)
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

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.value, this.color = Colors.white});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      );
}
