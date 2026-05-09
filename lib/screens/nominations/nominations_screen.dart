import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/nomination_model.dart';
import '../../providers/nomination_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';

class NominationsScreen extends StatefulWidget {
  const NominationsScreen({super.key});

  @override
  State<NominationsScreen> createState() => _NominationsScreenState();
}

class _NominationsScreenState extends State<NominationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NominationProvider>().loadNominations();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NominationProvider>();

    final pending = provider.nominations.where((n) => n.myResponse == 'pending').toList();
    final accepted = provider.nominations.where((n) => n.myResponse == 'accepted').toList();
    final declined = provider.nominations.where((n) => n.myResponse == 'declined').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        title: const Text('Nominations'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Accepted (${accepted.length})'),
            Tab(text: 'Declined (${declined.length})'),
          ],
        ),
      ),
      body: provider.isLoading
          ? const LoadingWidget(message: 'Loading nominations...')
          : TabBarView(
              controller: _tabController,
              children: [
                _NominationList(nominations: pending, showActions: true),
                _NominationList(nominations: accepted, showActions: false),
                _NominationList(nominations: declined, showActions: false),
              ],
            ),
    );
  }
}

class _NominationList extends StatelessWidget {
  final List<DriverNomination> nominations;
  final bool showActions;
  const _NominationList({required this.nominations, required this.showActions});

  @override
  Widget build(BuildContext context) {
    if (nominations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(showActions ? 'No pending nominations' : 'None yet', style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NominationProvider>().loadNominations(),
      child: ListView.builder(
        padding: EdgeInsets.all(context.hPad),
        itemCount: nominations.length,
        itemBuilder: (context, i) => _NominationCard(nomination: nominations[i], showActions: showActions),
      ),
    );
  }
}

class _NominationCard extends StatelessWidget {
  final DriverNomination nomination;
  final bool showActions;
  const _NominationCard({required this.nomination, required this.showActions});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NominationProvider>();

    return GestureDetector(
      onTap: () => context.push('/nominations/${nomination.groupId}', extra: nomination),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: context.rv(44.0, 48.0, 56.0), height: context.rv(44.0, 48.0, 56.0),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.groups, color: AppColors.primary, size: context.iconGlyph),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nomination.groupName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.fsTitle)),
                        Text(nomination.schoolName, style: TextStyle(color: AppColors.textSecondary, fontSize: context.fsBody)),
                      ],
                    ),
                  ),
                  _StatusBadge(response: nomination.myResponse),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _InfoChip(icon: Icons.directions_car, label: nomination.vehicleType),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.people, label: '${nomination.currentMembers}/${nomination.capacity} students'),
                  if (nomination.pickupAddress != null) ...[
                    const SizedBox(width: 8),
                    Expanded(child: _InfoChip(icon: Icons.location_on, label: nomination.pickupAddress!)),
                  ],
                ],
              ),
            ),
            if (showActions && nomination.isPending)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.respond(nomination.groupId, 'declined', onSuccess: () {}),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Decline'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => provider.respond(nomination.groupId, 'accepted', onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomination accepted!')));
                        }),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Accept'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String response;
  const _StatusBadge({required this.response});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (response) {
      case 'accepted': color = AppColors.success; label = 'Accepted'; break;
      case 'declined': color = AppColors.error; label = 'Declined'; break;
      default: color = AppColors.warning; label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
