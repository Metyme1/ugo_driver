import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/group_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadMyGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Groups')),
      body: RefreshIndicator(
        onRefresh: () => context.read<GroupProvider>().loadMyGroups(),
        child: provider.isLoading
            ? const LoadingWidget(message: 'Loading groups...')
            : provider.groups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.groups_outlined, size: 72, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        const Text('No active groups yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Accept a nomination to get started', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () => context.push('/nominations'),
                          icon: const Icon(Icons.pending_actions),
                          label: const Text('View Nominations'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(context.hPad),
                    itemCount: provider.groups.length,
                    itemBuilder: (context, i) {
                      final g = provider.groups[i];
                      final iconBox = context.rv(44.0, 52.0, 60.0);
                      return GestureDetector(
                        onTap: () => context.push('/groups/${g.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(context.hPad),
                            child: Row(
                              children: [
                                Container(
                                  width: iconBox, height: iconBox,
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.groups, color: AppColors.primary, size: context.iconGlyph),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(g.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.fsTitle)),
                                      const SizedBox(height: 2),
                                      Text(g.schoolName, style: TextStyle(color: AppColors.textSecondary, fontSize: context.fsBody)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _Chip(icon: Icons.people, label: '${g.currentMembers}/${g.capacity}'),
                                          const SizedBox(width: 8),
                                          _Chip(icon: Icons.directions_car, label: g.vehicleType),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _StatusDot(status: g.status),
                                    const SizedBox(height: 8),
                                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'open' ? AppColors.success : status == 'full' ? AppColors.warning : AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
