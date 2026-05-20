import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _NominationsScreenState extends State<NominationsScreen>
    with SingleTickerProviderStateMixin {
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NominationProvider>();

    final pending  = provider.nominations.where((n) => n.myResponse == 'pending').toList();
    final accepted = provider.nominations.where((n) => n.myResponse == 'accepted').toList();
    final declined = provider.nominations.where((n) => n.myResponse == 'declined').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Nominations',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
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
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              showActions ? 'No pending nominations' : 'None yet',
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<NominationProvider>().loadNominations(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(context.hPad, 16, context.hPad, 32),
        itemCount: nominations.length,
        itemBuilder: (context, i) => _NominationCard(
          nomination: nominations[i], showActions: showActions),
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
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: context.rv(46.0, 52.0, 58.0),
                    height: context.rv(46.0, 52.0, 58.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.groups_rounded, color: AppColors.primary, size: context.iconGlyph),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nomination.groupName,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: context.fsTitle,
                            color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(nomination.schoolName,
                          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: context.fsBody)),
                      ],
                    ),
                  ),
                  _StatusBadge(response: nomination.myResponse),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _InfoChip(icon: Icons.directions_car_rounded, label: nomination.vehicleType),
                  const SizedBox(width: 10),
                  _InfoChip(
                    icon: Icons.people_rounded,
                    label: '${nomination.currentMembers}/${nomination.capacity}',
                  ),
                  if (nomination.pickupAddress != null) ...[
                    const SizedBox(width: 10),
                    Expanded(child: _InfoChip(
                      icon: Icons.location_on_rounded, label: nomination.pickupAddress!)),
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
                      child: GestureDetector(
                        onTap: () => provider.respond(nomination.groupId, 'declined', onSuccess: () {}),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                              const SizedBox(width: 6),
                              Text('Decline',
                                style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w500, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => provider.respond(nomination.groupId, 'accepted', onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Nomination accepted!', style: GoogleFonts.outfit()),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ));
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('Accept',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
                            ],
                          ),
                        ),
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
      case 'declined': color = AppColors.error;   label = 'Declined'; break;
      default:         color = AppColors.warning;  label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
        style: GoogleFonts.outfit(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
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
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label,
            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}



