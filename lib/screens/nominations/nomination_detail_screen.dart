import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/nomination_model.dart';
import '../../providers/nomination_provider.dart';
import '../../widgets/common/app_button.dart';

class NominationDetailScreen extends StatelessWidget {
  final DriverNomination nomination;
  const NominationDetailScreen({super.key, required this.nomination});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NominationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Nomination Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.groups, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(nomination.groupName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(nomination.schoolName, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details
            _DetailSection(
              title: 'Group Details',
              items: [
                _DetailItem(icon: Icons.directions_car, label: 'Vehicle Type', value: nomination.vehicleType),
                _DetailItem(icon: Icons.people, label: 'Students', value: '${nomination.currentMembers} / ${nomination.capacity}'),
                if (nomination.pickupAddress != null)
                  _DetailItem(icon: Icons.location_on, label: 'Pickup Area', value: nomination.pickupAddress!),
                _DetailItem(icon: Icons.info_outline, label: 'Group Status', value: nomination.assignmentStatus),
              ],
            ),
            const SizedBox(height: 16),
            _DetailSection(
              title: 'Your Response',
              items: [
                _DetailItem(
                  icon: Icons.reply,
                  label: 'Status',
                  value: nomination.myResponse.toUpperCase(),
                  valueColor: nomination.myResponse == 'accepted'
                      ? AppColors.success
                      : nomination.myResponse == 'declined'
                          ? AppColors.error
                          : AppColors.warning,
                ),
                if (nomination.offeredAt != null)
                  _DetailItem(icon: Icons.access_time, label: 'Offered At', value: _formatDate(nomination.offeredAt!)),
                if (nomination.respondedAt != null)
                  _DetailItem(icon: Icons.done_all, label: 'Responded At', value: _formatDate(nomination.respondedAt!)),
              ],
            ),

            if (nomination.isPending) ...[
              const SizedBox(height: 32),
              AppButton(
                label: 'Accept Nomination',
                icon: Icons.check_circle,
                onPressed: () => provider.respond(nomination.groupId, 'accepted', onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomination accepted!')));
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
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _DetailSection({required this.title, required this.items});

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
          ...items,
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailItem({required this.icon, required this.label, required this.value, this.valueColor});

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
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
