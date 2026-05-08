import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/group_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_button.dart';

class ScanResultScreen extends StatelessWidget {
  final ScanResult result;
  const ScanResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final ridesPercent = result.ridesTotal > 0 ? result.ridesUsed / result.ridesTotal : 0.0;
    final isLowRides = result.ridesLeft <= 2;
    final isExpiringSoon = result.expiresAt.difference(DateTime.now()).inDays <= 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Result'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/scan'),
            child: const Text('Scan Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.hPad),
        child: Column(
          children: [
            // Success banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.hPad),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ride Recorded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.success)),
                        Text('QR scanned successfully', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Passenger info
            _Card(
              title: 'Passenger Info',
              children: [
                _Row(icon: Icons.person, label: 'Parent', value: result.parentName),
                _Row(icon: Icons.phone, label: 'Phone', value: result.parentPhone),
                if (result.childName != null)
                  _Row(icon: Icons.child_care, label: 'Student', value: result.childName!),
                if (result.childGrade != null)
                  _Row(icon: Icons.school, label: 'Grade', value: result.childGrade!),
              ],
            ),
            const SizedBox(height: 16),

            // Package info
            _Card(
              title: 'Package Info',
              children: [
                _Row(icon: Icons.inventory_2_outlined, label: 'Package', value: result.packageTitle),
                _Row(icon: Icons.route, label: 'Route', value: result.route),
                _Row(
                  icon: Icons.calendar_today,
                  label: 'Expires',
                  value: DateFormat('MMM d, yyyy').format(result.expiresAt),
                  valueColor: isExpiringSoon ? AppColors.warning : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rides usage
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rides Usage', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${result.ridesUsed} used', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        '${result.ridesLeft} left',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isLowRides ? AppColors.error : AppColors.success,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: ridesPercent,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ridesPercent >= 0.9 ? AppColors.error : ridesPercent >= 0.6 ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(child: Text('${result.ridesUsed} / ${result.ridesTotal} rides used', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),

                  if (isLowRides) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.warning_amber, color: AppColors.warning, size: 16),
                        const SizedBox(width: 8),
                        Text('Only ${result.ridesLeft} ride${result.ridesLeft == 1 ? '' : 's'} remaining!', style: const TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            AppButton(label: 'Done', onPressed: () => context.go('/home'), icon: Icons.home),
            const SizedBox(height: 12),
            AppButton(label: 'Scan Another', onPressed: () => context.go('/scan'), icon: Icons.qr_code_scanner, outlined: true),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

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
  final Color? valueColor;
  const _Row({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Flexible(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary, fontSize: 13), textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
