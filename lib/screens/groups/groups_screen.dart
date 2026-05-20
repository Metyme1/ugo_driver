import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        title: Text('My Groups',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<GroupProvider>().loadMyGroups(),
        color: AppColors.primary,
        child: provider.isLoading
            ? const LoadingWidget(message: 'Loading groups...')
            : provider.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
                          ),
                          const SizedBox(height: 16),
                          Text(provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => context.read<GroupProvider>().loadMyGroups(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Retry', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : provider.groups.isEmpty
                    ? Center(
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
                                child: const Icon(Icons.groups_outlined, size: 44, color: AppColors.primary),
                              ),
                              const SizedBox(height: 20),
                              Text('No active groups yet',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 18, color: AppColors.textPrimary)),
                              const SizedBox(height: 8),
                              Text('Accept a nomination to get started',
                                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
                                textAlign: TextAlign.center),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () => context.push('/nominations'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.pending_actions_rounded, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Text('View Nominations',
                                        style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(context.hPad, 16, context.hPad, 32),
                        itemCount: provider.groups.length,
                        itemBuilder: (context, i) {
                          final g = provider.groups[i];
                          return GestureDetector(
                            onTap: () => context.push('/groups/${g.id}'),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.06),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(context.hPad),
                                child: Row(
                                  children: [
                                    Container(
                                      width: context.rv(50.0, 56.0, 64.0),
                                      height: context.rv(50.0, 56.0, 64.0),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(Icons.groups_rounded, color: Colors.white, size: context.iconGlyph),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(g.name,
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: context.fsTitle, color: AppColors.textPrimary)),
                                          const SizedBox(height: 2),
                                          Text(g.schoolName,
                                            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: context.fsBody)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _Chip(icon: Icons.people_rounded, label: '${g.currentMembers}/${g.capacity}'),
                                              const SizedBox(width: 8),
                                              _Chip(icon: Icons.directions_car_rounded, label: g.vehicleType),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _StatusDot(status: g.status),
                                        const SizedBox(height: 10),
                                        const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
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
    final color = status == 'open'
        ? AppColors.success
        : status == 'full'
            ? AppColors.warning
            : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(status,
            style: GoogleFonts.outfit(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}


