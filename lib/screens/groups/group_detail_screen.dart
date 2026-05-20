import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../utils/responsive.dart';
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

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _service = GroupService();
  GroupModel? _group;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() { _isLoading = true; _error = null; });
    final response = await _service.getGroupDetail(widget.groupId);
    setState(() {
      _isLoading = false;
      if (response.success) { _group = response.data; }
      else { _error = response.error?.message; }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_group?.name ?? 'Group Detail'),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _loadGroup)
              : _group == null
                  ? const AppErrorWidget(message: 'Group not found')
                  : _buildBody(),
    );
  }

  Widget _buildBody() {
    final g = _group!;
    final activeMembers = g.members.where((m) => m.status == 'active').toList();
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                Icon(Icons.groups, color: Colors.white, size: context.rv(28.0, 36.0, 44.0)),
                const SizedBox(height: 12),
                Text(g.name, style: TextStyle(color: Colors.white, fontSize: context.fsHeadline, fontWeight: FontWeight.w500)),
                Text(g.schoolName, style: TextStyle(color: Colors.white70, fontSize: context.fsBody)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _HeaderStat(label: 'Students', value: '${g.currentMembers}/${g.capacity}'),
                    const SizedBox(width: 24),
                    _HeaderStat(label: 'Spots Left', value: '${g.spotsLeft}'),
                    const SizedBox(width: 24),
                    _HeaderStat(label: 'Status', value: g.status.toUpperCase()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Group info
          _Section(
            title: 'Group Info',
            children: [
              _Row(icon: Icons.directions_car, label: 'Vehicle', value: g.vehicleType),
              if (g.pickupAddress != null) _Row(icon: Icons.location_on, label: 'Pickup', value: g.pickupAddress!),
              if (g.scheduleTime != null) _Row(icon: Icons.access_time, label: 'Schedule', value: g.scheduleTime!),
              if (g.createdAt != null)
                _Row(icon: Icons.calendar_today, label: 'Created', value: '${g.createdAt!.day}/${g.createdAt!.month}/${g.createdAt!.year}'),
            ],
          ),
          const SizedBox(height: 16),

          // Pickup map
          _PickupMapSection(members: activeMembers),

          // Students list
          _StudentListSection(members: activeMembers),

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scan Passenger QR', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      Text('Tap the Scan QR button on the home screen to record a ride', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Pickup map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PickupMapSection extends StatefulWidget {
  final List<GroupMember> members;
  const _PickupMapSection({required this.members});

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

    for (final m in widget.members) {
      final lat = m.destinationLat;
      final lng = m.destinationLng;
      if (lat != null && lng != null) {
        schoolPos = LatLng(lat, lng);
        break;
      }
    }

    if (schoolPos != null) {
      final schoolName = widget.members.isNotEmpty
          ? widget.members.first.destinationName
          : 'School';
      markers.add(Marker(
        markerId: const MarkerId('school'),
        position: schoolPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: schoolName),
      ));
    }

    for (int i = 0; i < widget.members.length; i++) {
      final m = widget.members[i];
      final coords = m.pickupCoordinates;
      if (coords == null || coords.length < 2) continue;

      // coords stored as [lng, lat] (GeoJSON) â€” Google Maps needs LatLng(lat, lng)
      final pickupPos = LatLng(coords[1], coords[0]);
      markers.add(Marker(
        markerId: MarkerId('pickup_$i'),
        position: pickupPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '${i + 1}. ${m.childName}',
          snippet: m.pickupAddress,
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
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textPrimary),
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

// â”€â”€â”€ Student list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StudentListSection extends StatelessWidget {
  final List<GroupMember> members;
  const _StudentListSection({required this.members});

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
                'Students (${members.length})',
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        if (members.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Text('No students yet', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          )
        else
          ...members.asMap().entries.map((e) => _StudentCard(index: e.key + 1, member: e.value)),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final int index;
  final GroupMember member;
  const _StudentCard({required this.index, required this.member});

  String? get _distanceLabel {
    final coords = member.pickupCoordinates;
    if (coords == null || coords.length < 2) return null;
    final schoolLat = member.destinationLat;
    final schoolLng = member.destinationLng;
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
                        style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.primary, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.childName,
                          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                      if (member.childGrade != null)
                        Text('Grade ${member.childGrade}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      if (member.parentName != null)
                        Text(member.parentName!,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (member.status != 'active')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(member.status,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (member.pickupAddress != null)
            _CardRow(
              icon: Icons.trip_origin,
              iconColor: Colors.green,
              label: 'Pickup',
              value: member.pickupAddress!,
              subValue: member.pickupLandmark,
            ),
          _CardRow(
            icon: Icons.school,
            iconColor: AppColors.primary,
            label: 'Destination',
            value: member.destinationName,
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

// â”€â”€â”€ Shared widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});

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
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w400), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}



