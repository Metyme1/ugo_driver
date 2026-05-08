import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';

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
      if (response.success) _group = response.data;
      else _error = response.error?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_group?.name ?? 'Group Detail')),
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
                Text(g.name, style: TextStyle(color: Colors.white, fontSize: context.fsHeadline, fontWeight: FontWeight.bold)),
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

          // Details
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scan Passenger QR', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('Tap the Scan QR button on the home screen to record a ride', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
