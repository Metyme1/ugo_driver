import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/nomination_model.dart';
import '../../providers/nomination_provider.dart';
import '../../services/nomination_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_widget.dart';

double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLng = (lng2 - lng1) * math.pi / 180;
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

class NominationDetailScreen extends StatefulWidget {
  final DriverNomination nomination;
  const NominationDetailScreen({super.key, required this.nomination});

  @override
  State<NominationDetailScreen> createState() => _NominationDetailScreenState();
}

class _NominationDetailScreenState extends State<NominationDetailScreen> {
  final _service = NominationService();
  NominationDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() { _loading = true; _error = null; });
    final res = await _service.getNominationDetail(widget.nomination.groupId);
    if (!mounted) return;
    if (res.success) {
      setState(() { _detail = res.data; _loading = false; });
    } else {
      setState(() { _error = res.error?.message ?? 'Failed to load details'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NominationProvider>();
    final nom = widget.nomination;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        title: const Text('Nomination Detail'),
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading details...')
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadDetail)
              : _DetailBody(detail: _detail!, provider: provider, nomination: nom),
    );
  }
}

// ─── Body ──────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  final NominationDetail detail;
  final NominationProvider provider;
  final DriverNomination nomination;

  const _DetailBody({
    required this.detail,
    required this.provider,
    required this.nomination,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Group header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.hPad),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.groups, color: Colors.white, size: context.rv(28.0, 32.0, 40.0)),
                const SizedBox(height: 12),
                Text(detail.groupName,
                    style: TextStyle(color: Colors.white, fontSize: context.fsHeadline, fontWeight: FontWeight.bold)),
                Text(detail.schoolName,
                    style: TextStyle(color: Colors.white70, fontSize: context.fsBody)),
                if (detail.description != null) ...[
                  const SizedBox(height: 8),
                  Text(detail.description!,
                      style: const TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Group details ─────────────────────────────────────────────────
          _Section(
            title: 'Group Details',
            items: [
              _Item(icon: Icons.directions_car, label: 'Vehicle Type', value: detail.vehicleType),
              _Item(icon: Icons.people, label: 'Students', value: '${detail.currentMembers} / ${detail.capacity}'),
              if (detail.pickupAddress != null)
                _Item(icon: Icons.location_on, label: 'Pickup Area', value: detail.pickupAddress!),
              if (detail.basePrice != null)
                _Item(icon: Icons.payments_outlined, label: 'Monthly Price', value: 'ETB ${detail.basePrice!.toStringAsFixed(0)}'),
              _Item(icon: Icons.info_outline, label: 'Group Status', value: detail.assignmentStatus.replaceAll('_', ' ')),
            ],
          ),
          const SizedBox(height: 16),

          // ── Your response ─────────────────────────────────────────────────
          _Section(
            title: 'Your Response',
            items: [
              _Item(
                icon: Icons.reply,
                label: 'Status',
                value: detail.myResponse.toUpperCase(),
                valueColor: detail.myResponse == 'accepted'
                    ? AppColors.success
                    : detail.myResponse == 'declined'
                        ? AppColors.error
                        : AppColors.warning,
              ),
              if (detail.offeredAt != null)
                _Item(icon: Icons.access_time, label: 'Offered At', value: _fmt(detail.offeredAt!)),
              if (detail.respondedAt != null)
                _Item(icon: Icons.done_all, label: 'Responded At', value: _fmt(detail.respondedAt!)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Pickup map ────────────────────────────────────────────────────
          _PickupMapSection(students: detail.students),

          // ── Students ──────────────────────────────────────────────────────
          _StudentList(students: detail.students),

          // ── Actions ───────────────────────────────────────────────────────
          if (detail.isPending) ...[
            const SizedBox(height: 32),
            AppButton(
              label: 'Accept Nomination',
              icon: Icons.check_circle,
              onPressed: () => provider.respond(nomination.groupId, 'accepted', onSuccess: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Nomination accepted!')));
                Navigator.pop(context);
              }),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Decline',
              icon: Icons.cancel,
              outlined: true,
              color: AppColors.error,
              onPressed: () => provider.respond(nomination.groupId, 'declined', onSuccess: () {
                Navigator.pop(context);
              }),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Pickup map section ────────────────────────────────────────────────────

class _PickupMapSection extends StatefulWidget {
  final List<NominationStudent> students;
  const _PickupMapSection({required this.students});

  @override
  State<_PickupMapSection> createState() => _PickupMapSectionState();
}

class _PickupMapSectionState extends State<_PickupMapSection> {
  GoogleMapController? _mapCtrl;
  late final Set<Marker> _markers;
  late final Set<Polyline> _polylines;

  @override
  void initState() {
    super.initState();
    _computeOverlays();
  }

  void _computeOverlays() {
    final markers = <Marker>{};
    final polylines = <Polyline>{};
    LatLng? schoolPos;

    for (final s in widget.students) {
      final lat = s.destinationLat;
      final lng = s.destinationLng;
      if (lat != null && lng != null) {
        schoolPos = LatLng(lat, lng);
        break;
      }
    }

    if (schoolPos != null) {
      final schoolName = widget.students.isNotEmpty
          ? widget.students.first.destinationName
          : 'School';
      markers.add(Marker(
        markerId: const MarkerId('school'),
        position: schoolPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: schoolName),
      ));
    }

    for (int i = 0; i < widget.students.length; i++) {
      final s = widget.students[i];
      final coords = s.pickupCoordinates;
      if (coords == null || coords.length < 2) continue;

      // coords stored as [lng, lat] (GeoJSON) — Google Maps needs LatLng(lat, lng)
      final pickupPos = LatLng(coords[1], coords[0]);
      markers.add(Marker(
        markerId: MarkerId('pickup_$i'),
        position: pickupPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '${i + 1}. ${s.name}',
          snippet: s.pickupAddress,
        ),
      ));

      if (schoolPos != null) {
        polylines.add(Polyline(
          polylineId: PolylineId('route_$i'),
          points: [pickupPos, schoolPos],
          color: Colors.blue.withValues(alpha: 0.45),
          width: 2,
          patterns: [PatternItem.dash(16), PatternItem.gap(8)],
        ));
      }
    }

    _markers = markers;
    _polylines = polylines;
  }

  void _fitBounds() {
    if (_mapCtrl == null || _markers.isEmpty || !mounted) return;

    if (_markers.length == 1) {
      _mapCtrl!.animateCamera(CameraUpdate.newLatLngZoom(_markers.first.position, 14));
      return;
    }

    double minLat = _markers.first.position.latitude;
    double maxLat = minLat;
    double minLng = _markers.first.position.longitude;
    double maxLng = minLng;

    for (final m in _markers) {
      minLat = math.min(minLat, m.position.latitude);
      maxLat = math.max(maxLat, m.position.latitude);
      minLng = math.min(minLng, m.position.longitude);
      maxLng = math.max(maxLng, m.position.longitude);
    }

    if (maxLat - minLat < 0.002) { minLat -= 0.005; maxLat += 0.005; }
    if (maxLng - minLng < 0.002) { minLng -= 0.005; maxLng += 0.005; }

    _mapCtrl!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }

  @override
  void dispose() {
    _mapCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_markers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(Icons.map_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Pickup Locations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _markers.first.position,
                zoom: 13,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (ctrl) {
                _mapCtrl = ctrl;
                Future.delayed(const Duration(milliseconds: 400), _fitBounds);
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _MapLegendDot(color: Colors.green.shade600),
            const SizedBox(width: 4),
            const Text('Pickup', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(width: 16),
            _MapLegendDot(color: Colors.blue.shade700),
            const SizedBox(width: 4),
            const Text('School', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MapLegendDot extends StatelessWidget {
  final Color color;
  const _MapLegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Student list section ──────────────────────────────────────────────────

class _StudentList extends StatelessWidget {
  final List<NominationStudent> students;
  const _StudentList({required this.students});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Students (${students.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        if (students.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('No student information available',
                style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          )
        else
          ...students.asMap().entries.map((e) => _StudentCard(index: e.key + 1, student: e.value)),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final int index;
  final NominationStudent student;
  const _StudentCard({required this.index, required this.student});

  String? get _distanceLabel {
    final coords = student.pickupCoordinates;
    if (coords == null || coords.length < 2) return null;
    final schoolLat = student.destinationLat;
    final schoolLng = student.destinationLng;
    if (schoolLat == null || schoolLng == null) return null;
    final dist = _haversineKm(coords[1], coords[0], schoolLat, schoolLng);
    return '${dist.toStringAsFixed(1)} km from pickup';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('$index',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('Grade ${student.grade}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Pickup location
          if (student.pickupAddress != null)
            _CardRow(
              icon: Icons.trip_origin,
              iconColor: Colors.green,
              label: 'Pickup',
              value: student.pickupAddress!,
              subValue: student.pickupLandmark,
            ),

          // Destination school with distance
          _CardRow(
            icon: Icons.school,
            iconColor: AppColors.primary,
            label: 'Destination',
            value: student.destinationName,
            subValue: _distanceLabel,
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subValue;
  const _CardRow({required this.icon, required this.iconColor, required this.label, required this.value, this.subValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                if (subValue != null && subValue!.isNotEmpty)
                  Text(subValue!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable section widget ───────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _Item({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(value,
                style: TextStyle(fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
