import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/offline_qr_service.dart';
import '../../widgets/common/app_button.dart';

class OfflineScanResultScreen extends StatefulWidget {
  final String purchaseId;
  const OfflineScanResultScreen({super.key, required this.purchaseId});

  @override
  State<OfflineScanResultScreen> createState() => _OfflineScanResultScreenState();
}

class _OfflineScanResultScreenState extends State<OfflineScanResultScreen> {
  int _selectedRides = 1;
  bool _queued = false;

  Future<void> _queue() async {
    await OfflineQrService.enqueue(widget.purchaseId, _selectedRides);
    if (!mounted) return;
    setState(() => _queued = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.headerGradient)),
        title: const Text('Offline Scan'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/scan'),
            child: const Text('Scan Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _queued ? _buildQueued() : _buildConfirm(),
      ),
    );
  }

  Widget _buildConfirm() {
    return Column(
      children: [
        // Offline banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.wifi_off, color: AppColors.warning, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Offline Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.warning)),
                    Text('QR verified locally. Ride will sync when online.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // QR valid card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user, color: AppColors.primary, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QR Signature Valid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    Text('Passenger QR is genuine. Select rides to queue.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Ride selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rides to Deduct', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Will be recorded once back online', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CounterBtn(icon: Icons.remove, enabled: _selectedRides > 1, onTap: () => setState(() => _selectedRides--)),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      Text('$_selectedRides', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(_selectedRides == 1 ? 'ride' : 'rides', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  _CounterBtn(icon: Icons.add, enabled: _selectedRides < 10, onTap: () => setState(() => _selectedRides++)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        AppButton(label: 'Queue Ride', onPressed: _queue, icon: Icons.queue),
        const SizedBox(height: 12),
        AppButton(label: 'Cancel', onPressed: () => context.go('/scan'), icon: Icons.close, outlined: true),
      ],
    );
  }

  Widget _buildQueued() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 48),
              const SizedBox(height: 12),
              Text(
                '$_selectedRides ride${_selectedRides == 1 ? '' : 's'} queued',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.success),
              ),
              const SizedBox(height: 6),
              const Text(
                'Will be deducted from the passenger\'s account when you reconnect.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppButton(label: 'Scan Another', onPressed: () => context.go('/scan'), icon: Icons.qr_code_scanner),
        const SizedBox(height: 12),
        AppButton(label: 'Done', onPressed: () => context.go('/home'), icon: Icons.home, outlined: true),
      ],
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: enabled ? Colors.white : Colors.grey.shade400, size: 22),
      ),
    );
  }
}
