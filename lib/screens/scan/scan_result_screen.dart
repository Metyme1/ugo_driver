import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_button.dart';

class ScanResultScreen extends StatefulWidget {
  final ScanResult result;
  const ScanResultScreen({super.key, required this.result});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final _service = GroupService();
  int _selectedRides = 1;
  bool _isConfirming = false;
  bool _confirmed = false;
  int _ridesDeducted = 0;
  int _ridesLeftAfter = 0;

  Future<void> _confirm() async {
    setState(() => _isConfirming = true);
    final response = await _service.confirmScan(widget.result.purchaseId, _selectedRides);
    if (!mounted) return;
    setState(() => _isConfirming = false);

    if (response.success && response.data != null) {
      setState(() {
        _confirmed = true;
        _ridesDeducted = response.data!['ridesDeducted'] as int;
        _ridesLeftAfter = response.data!['ridesLeft'] as int;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error?.message ?? 'Confirmation failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isExpiringSoon = widget.result.expiresAt.difference(DateTime.now()).inDays <= 3;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_confirmed ? l.rideRecorded : l.passengerDetails),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/scan'),
            child: Text(l.scanAgain, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.hPad),
        child: _confirmed ? _buildSuccessView(l) : _buildPreviewView(l, isExpiringSoon),
      ),
    );
  }

  Widget _buildPreviewView(AppLocalizations l, bool isExpiringSoon) {
    final ridesLeft = widget.result.ridesLeft;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.qrVerified, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: AppColors.primary)),
                    Text(l.selectRidesToDeduct, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _Card(
          title: l.passengerInfo,
          children: [
            _Row(icon: Icons.person, label: l.parent, value: widget.result.parentName),
            _Row(icon: Icons.phone, label: l.phone, value: widget.result.parentPhone),
            if (widget.result.childName != null)
              _Row(icon: Icons.child_care, label: l.student, value: widget.result.childName!),
            if (widget.result.childGrade != null)
              _Row(icon: Icons.school, label: l.grade, value: widget.result.childGrade!),
          ],
        ),
        const SizedBox(height: 16),

        _Card(
          title: l.packageInfo,
          children: [
            _Row(icon: Icons.inventory_2_outlined, label: l.package, value: widget.result.packageTitle),
            _Row(icon: Icons.route, label: l.route, value: widget.result.route),
            _Row(
              icon: Icons.calendar_today,
              label: l.expires,
              value: DateFormat('MMM d, yyyy').format(widget.result.expiresAt),
              valueColor: isExpiringSoon ? AppColors.warning : null,
            ),
          ],
        ),
        const SizedBox(height: 16),

        _RidesBalanceCard(
          ridesUsed: widget.result.ridesUsed,
          ridesTotal: widget.result.ridesTotal,
          ridesLeft: ridesLeft,
          l: l,
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.ridesToDeduct, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(l.payingForOthers, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CounterButton(
                    icon: Icons.remove,
                    enabled: _selectedRides > 1,
                    onTap: () => setState(() => _selectedRides--),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      Text('$_selectedRides',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                      Text(_selectedRides == 1 ? l.ride : l.rides,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  _CounterButton(
                    icon: Icons.add,
                    enabled: _selectedRides < ridesLeft,
                    onTap: () => setState(() => _selectedRides++),
                  ),
                ],
              ),
              if (_selectedRides > 1) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l.deductingForOthers(_selectedRides),
                      style: const TextStyle(color: AppColors.primary, fontSize: 12))),
                  ]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        AppButton(
          label: _selectedRides == 1 ? l.confirmRideCount(1) : l.confirmRidesCount(_selectedRides),
          onPressed: _isConfirming ? null : _confirm,
          icon: _isConfirming ? null : Icons.check_circle_outline,
          isLoading: _isConfirming,
        ),
        const SizedBox(height: 12),
        AppButton(label: l.cancel, onPressed: () => context.go('/scan'), icon: Icons.close, outlined: true),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSuccessView(AppLocalizations l) {
    final isLow = _ridesLeftAfter <= 2;

    return Column(
      children: [
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
              const Icon(Icons.check_circle, color: AppColors.success, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ridesDeducted == 1 ? l.rideRecorded : l.ridesRecorded(_ridesDeducted),
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: AppColors.success),
                    ),
                    Text(
                      _ridesDeducted == 1
                          ? l.rideDeductedFrom(_ridesDeducted, widget.result.parentName)
                          : l.ridesDeductedFrom(_ridesDeducted, widget.result.parentName),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _Card(
          title: l.passengerInfo,
          children: [
            _Row(icon: Icons.person, label: l.parent, value: widget.result.parentName),
            if (widget.result.childName != null)
              _Row(icon: Icons.child_care, label: l.student, value: widget.result.childName!),
            _Row(icon: Icons.inventory_2_outlined, label: l.package, value: widget.result.packageTitle),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.updatedBalance, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 6),
                    Text(l.deductedCount(_ridesDeducted), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ]),
                  Text(l.ridesLeftCount(_ridesLeftAfter),
                    style: TextStyle(fontWeight: FontWeight.w500, color: isLow ? AppColors.error : AppColors.success, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: widget.result.ridesTotal > 0
                      ? (_ridesLeftAfter / widget.result.ridesTotal).clamp(0.0, 1.0)
                      : 0.0,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(isLow ? AppColors.error : AppColors.success),
                ),
              ),
              const SizedBox(height: 6),
              Center(child: Text(l.ridesUsedOf(widget.result.ridesTotal - _ridesLeftAfter, widget.result.ridesTotal),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              if (isLow) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.warning_amber, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _ridesLeftAfter == 1 ? l.onlyRideRemaining(_ridesLeftAfter) : l.onlyRidesRemaining(_ridesLeftAfter),
                      style: const TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        AppButton(label: l.done, onPressed: () => context.go('/home'), icon: Icons.home),
        const SizedBox(height: 12),
        AppButton(label: l.scanAnother, onPressed: () => context.go('/scan'), icon: Icons.qr_code_scanner, outlined: true),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _RidesBalanceCard extends StatelessWidget {
  final int ridesUsed;
  final int ridesTotal;
  final int ridesLeft;
  final AppLocalizations l;
  const _RidesBalanceCard({required this.ridesUsed, required this.ridesTotal, required this.ridesLeft, required this.l});

  @override
  Widget build(BuildContext context) {
    final isLow = ridesLeft <= 2;
    final percent = ridesTotal > 0 ? ridesUsed / ridesTotal : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.currentBalance, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.deductedCount(ridesUsed), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text(l.ridesLeftCount(ridesLeft),
                style: TextStyle(fontWeight: FontWeight.w500, color: isLow ? AppColors.error : AppColors.success, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 0.9 ? AppColors.error : percent >= 0.6 ? AppColors.warning : AppColors.success),
            ),
          ),
          const SizedBox(height: 6),
          Center(child: Text(l.ridesUsedOf(ridesUsed, ridesTotal), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          if (isLow) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.warning_amber, color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                Text(ridesLeft == 1 ? l.onlyRideRemaining(ridesLeft) : l.onlyRidesRemaining(ridesLeft),
                  style: const TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: enabled ? Colors.white : Colors.grey.shade400, size: 22),
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
          Flexible(child: Text(value,
            style: TextStyle(fontWeight: FontWeight.w400, color: valueColor ?? AppColors.textPrimary, fontSize: 13),
            textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
