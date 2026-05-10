import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/university_scan_model.dart';
import '../../services/university_scan_service.dart';
import '../../services/api_service.dart';
import '../../widgets/common/app_button.dart';

class UniversityScanResultScreen extends StatefulWidget {
  final UniversityBookingPreview preview;
  const UniversityScanResultScreen({super.key, required this.preview});

  @override
  State<UniversityScanResultScreen> createState() =>
      _UniversityScanResultScreenState();
}

class _UniversityScanResultScreenState
    extends State<UniversityScanResultScreen> {
  final _service = UniversityScanService(ApiService());
  bool _confirming = false;
  UniversityScanResult? _result;

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    try {
      final result = await _service.confirmScan(widget.preview.bookingId);
      if (!mounted) return;
      setState(() {
        _result = result;
        _confirming = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        title: Text(
          _result != null ? 'Boarding Confirmed' : 'University Ticket',
          style: const TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/scan'),
            child: const Text('Scan Again',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _result != null
            ? _buildSuccessView(_result!)
            : _buildPreviewView(),
      ),
    );
  }

  Widget _buildPreviewView() {
    final p = widget.preview;
    return Column(
      children: [
        // QR verified banner
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
              Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('University Ticket Scanned',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary)),
                    Text('Review details and confirm boarding',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Passenger info
        _InfoCard(title: 'Passenger', rows: [
          _InfoRow(Icons.person, 'Name', p.passengerName),
          if (p.studentId.isNotEmpty)
            _InfoRow(Icons.badge_outlined, 'Student ID', p.studentId),
        ]),
        const SizedBox(height: 14),

        // Trip info
        _InfoCard(title: 'Trip Details', rows: [
          _InfoRow(Icons.route, 'Route', p.routeLabel),
          _InfoRow(Icons.event_seat, 'Seat', 'Seat ${p.seatNumber}'),
          _InfoRow(Icons.calendar_today, 'Date', p.departureDate),
          _InfoRow(Icons.access_time, 'Time', p.departureTime),
        ]),
        const SizedBox(height: 14),

        // Fare
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.payments_outlined,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Text('Ticket Fare',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ],
              ),
              Text(
                '${p.fare.toStringAsFixed(0)} ETB',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.success),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        AppButton(
          label: 'Confirm Boarding',
          onPressed: _confirming ? null : _confirm,
          icon: _confirming ? null : Icons.check_circle_outline,
          isLoading: _confirming,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Cancel',
          onPressed: () => context.go('/scan'),
          icon: Icons.close,
          outlined: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSuccessView(UniversityScanResult r) {
    return Column(
      children: [
        // Success banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Boarding Confirmed',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: AppColors.success)),
                    Text('${r.passengerName} — Seat ${r.seatNumber}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Earning breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Your Earning',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 16),
              _EarningRow('Ticket fare', r.grossAmount, AppColors.info),
              const SizedBox(height: 8),
              _EarningRow(
                  'UGO commission (5%)', -r.ugoCommission, AppColors.warning),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: AppColors.border),
              ),
              _EarningRow('Your net earning', r.netAmount, AppColors.success,
                  large: true),
            ],
          ),
        ),
        const SizedBox(height: 28),

        AppButton(
          label: 'Done',
          onPressed: () => context.go('/home'),
          icon: Icons.home,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Scan Another',
          onPressed: () => context.go('/scan'),
          icon: Icons.qr_code_scanner,
          outlined: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ),
          const Divider(height: 1),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool large;
  const _EarningRow(this.label, this.amount, this.color, {this.large = false});

  @override
  Widget build(BuildContext context) {
    final prefix = amount < 0 ? '-' : '+';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: large ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: large ? FontWeight.bold : FontWeight.normal,
                fontSize: large ? 15 : 13)),
        Text(
          '$prefix ${amount.abs().toStringAsFixed(0)} ETB',
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: large ? 17 : 14),
        ),
      ],
    );
  }
}
