import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/driver_billing_model.dart';
import '../../providers/driver_billing_provider.dart';

class DriverBillingScreen extends StatefulWidget {
  const DriverBillingScreen({super.key});

  @override
  State<DriverBillingScreen> createState() => _DriverBillingScreenState();
}

class _DriverBillingScreenState extends State<DriverBillingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverBillingProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Earnings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Earnings'),
            Tab(text: 'Platform Fee'),
          ],
        ),
      ),
      body: Column(
        children: [
          _MonthSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _SummaryTab(),
                _EarningsTab(),
                _PlatformFeeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Month selector
// ─────────────────────────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  static final List<String> _months = _buildMonths();

  static List<String> _buildMonths() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });
  }

  static String _label(String my) {
    final p = my.split('-');
    const n = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${n[int.parse(p[1])]} ${p[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverBillingProvider>(
      builder: (_, p, __) {
        final idx = _months.indexOf(p.selectedMonth);
        return Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: idx > 0 ? () => p.selectMonth(_months[idx - 1]) : null,
              ),
              Text(
                _label(p.selectedMonth),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: idx < _months.length - 1
                    ? () => p.selectMonth(_months[idx + 1])
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Summary
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryTab extends StatelessWidget {
  const _SummaryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverBillingProvider>(
      builder: (_, p, __) {
        if (p.summaryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final s = p.summary ?? DriverMonthlySummary.empty(p.selectedMonth);
        return RefreshIndicator(
          onRefresh: p.loadSummary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (p.summaryError != null) _ErrorBanner(p.summaryError!),
                _BreakdownCard(summary: s),
                const SizedBox(height: 12),
                _ActivityRow(summary: s),
                const SizedBox(height: 12),
                _PayoutCard(summary: s),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final DriverMonthlySummary summary;
  const _BreakdownCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Revenue Breakdown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          _BRow(
            label: 'Gross Revenue',
            sub: 'from parents',
            amount: summary.grossTotal,
            color: AppColors.info,
            icon: Icons.arrow_downward,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border),
          ),
          _BRow(
            label: 'UGO Commission',
            sub: '15% platform fee',
            amount: summary.ugoCommissionTotal,
            color: AppColors.warning,
            icon: Icons.remove,
            negative: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border, thickness: 2),
          ),
          _BRow(
            label: 'Your Net Earnings',
            sub: 'before platform sub',
            amount: summary.netEarnings,
            color: AppColors.success,
            icon: Icons.check_circle_outline,
            large: true,
          ),
        ],
      ),
    );
  }
}

class _BRow extends StatelessWidget {
  final String label;
  final String sub;
  final double amount;
  final Color color;
  final IconData icon;
  final bool negative;
  final bool large;

  const _BRow({
    required this.label,
    required this.sub,
    required this.amount,
    required this.color,
    required this.icon,
    this.negative = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: large ? FontWeight.bold : FontWeight.w500,
                      fontSize: large ? 15 : 14)),
              Text(sub,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Text(
          '${negative ? '-' : '+'} ${amount.toStringAsFixed(0)} ETB',
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: large ? 17 : 15),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final DriverMonthlySummary summary;
  const _ActivityRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatBox(
          icon: Icons.directions_car_outlined,
          value: '${summary.tripCount}',
          label: 'Trips Done',
          color: AppColors.primary,
        )),
        const SizedBox(width: 12),
        Expanded(child: _StatBox(
          icon: Icons.receipt_long_outlined,
          value: '${summary.subscriptionCount}',
          label: 'Subscriptions',
          color: AppColors.secondary,
        )),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.icon, required this.value,
    required this.label, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final DriverMonthlySummary summary;
  const _PayoutCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final feeStatus = summary.platformFeeStatus;
    final feeColor  = _color(feeStatus);
    final feeLabel  = feeStatus.toUpperCase().replaceAll('_', ' ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Estimated Payout',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${summary.estimatedPayout.toStringAsFixed(0)} ETB',
            style: const TextStyle(
                fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.success),
          ),
          const Text('Take-home this month',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _PRow('Net earnings',
                    '+${summary.netEarnings.toStringAsFixed(0)} ETB',
                    AppColors.success),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Platform subscription',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: feeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: feeColor),
                          ),
                          child: Text(feeLabel,
                              style: TextStyle(
                                  color: feeColor, fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text('- ${summary.driverPlatformFee.toStringAsFixed(0)} ETB',
                            style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (feeStatus == 'due' || feeStatus == 'overdue') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => DefaultTabController.of(context).animateTo(2),
                icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                label: const Text('Pay Platform Fee',
                    style: TextStyle(color: AppColors.warning)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.warning)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _color(String s) {
    switch (s) {
      case 'paid':            return AppColors.success;
      case 'waived':          return AppColors.info;
      case 'pending_payment': return AppColors.warning;
      case 'overdue':         return AppColors.error;
      default:                return AppColors.warning;
    }
  }
}

class _PRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _PRow(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Earnings list
// ─────────────────────────────────────────────────────────────────────────────

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverBillingProvider>(
      builder: (_, p, __) {
        if (p.earningsLoading) return const Center(child: CircularProgressIndicator());
        if (p.earningsError != null) return _RetryView(p.earningsError!, p.loadEarnings);
        if (p.earnings.isEmpty) {
          return const _EmptyView(
            icon: Icons.receipt_long_outlined,
            message: 'No earnings recorded this month.',
          );
        }
        return RefreshIndicator(
          onRefresh: p.loadEarnings,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: p.earnings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _EarningCard(earning: p.earnings[i]),
          ),
        );
      },
    );
  }
}

class _EarningCard extends StatelessWidget {
  final DriverEarningRecord earning;
  const _EarningCard({required this.earning});

  static const _routeLabels = {
    'morning_to_school':   'Morning → School  07:00',
    'midday_to_home':      'Midday → Home  12:00',
    'afternoon_to_school': 'Afternoon → School  14:00',
    'afternoon_to_home':   'Afternoon → Home  16:30',
  };

  static Color _typeColor(String type) {
    switch (type) {
      case 'trip_earning':        return AppColors.primary;
      case 'university_ride':     return const Color(0xFF7C3AED);
      default:                    return AppColors.secondary;
    }
  }

  static IconData _typeIcon(String type) {
    switch (type) {
      case 'trip_earning':        return Icons.directions_car_outlined;
      case 'university_ride':     return Icons.school_outlined;
      default:                    return Icons.receipt_outlined;
    }
  }

  static String _typeTag(String type) {
    switch (type) {
      case 'trip_earning':        return 'TRIP';
      case 'university_ride':     return 'UNI';
      default:                    return 'SUB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(earning.type);
    final icon  = _typeIcon(earning.type);
    final isTrip = earning.type == 'trip_earning';
    final isUni  = earning.type == 'university_ride';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isUni
                            ? (earning.description ?? 'University Ride')
                            : (earning.groupName ?? 'Group'),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _typeTag(earning.type),
                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isUni
                      ? 'Boarding confirmed'
                      : isTrip
                          ? (_routeLabels[earning.routeType] ?? earning.routeType ?? '')
                          : 'Subscription verified',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                if (earning.earnedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _fmt(earning.earnedAt!),
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Badge('${earning.grossAmount.toStringAsFixed(0)} gross',
                        AppColors.info),
                    const SizedBox(width: 6),
                    _Badge('- ${earning.ugoCommission.toStringAsFixed(0)} UGO',
                        AppColors.warning),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${earning.netAmount.toStringAsFixed(0)}\nETB',
            textAlign: TextAlign.right,
            style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.2),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — Platform Fee
// ─────────────────────────────────────────────────────────────────────────────

class _PlatformFeeTab extends StatelessWidget {
  const _PlatformFeeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverBillingProvider>(
      builder: (_, p, __) {
        if (p.platformLoading) return const Center(child: CircularProgressIndicator());
        if (p.platformError != null) {
          return _RetryView(p.platformError!, p.loadPlatformSubscriptions);
        }
        if (p.platformSubs.isEmpty) {
          return const _EmptyView(
            icon: Icons.subscriptions_outlined,
            message: 'No platform subscription records yet.\nYour monthly fee will appear here.',
          );
        }
        return RefreshIndicator(
          onRefresh: p.loadPlatformSubscriptions,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: p.platformSubs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final sub = p.platformSubs[i];
              return _PlatformCard(
                sub: sub,
                highlight: sub.monthYear == p.selectedMonth,
                onPay: sub.isDue ? () => _showPaySheet(context, sub) : null,
              );
            },
          ),
        );
      },
    );
  }

  void _showPaySheet(BuildContext ctx, DriverPlatformSubscription sub) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PaySheet(sub: sub),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final DriverPlatformSubscription sub;
  final bool highlight;
  final VoidCallback? onPay;

  const _PlatformCard({required this.sub, required this.highlight, this.onPay});

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(sub.status);
    final sl = sub.status.toUpperCase().replaceAll('_', ' ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: highlight
            ? const Border.fromBorderSide(BorderSide(color: AppColors.primary, width: 1.5))
            : null,
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: highlight ? 0.08 : 0.04),
            blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.subscriptions_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_monthFull(sub.monthYear),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sc.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sc),
                ),
                child: Text(sl,
                    style: TextStyle(color: sc, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${sub.vehicleType[0].toUpperCase()}${sub.vehicleType.substring(1)} vehicle',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('${sub.fee.toStringAsFixed(0)} ETB',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24)),
                  ],
                ),
              ),
              if (sub.isPaid || sub.isWaived)
                Icon(
                  sub.isPaid ? Icons.check_circle : Icons.do_not_disturb_on,
                  color: sub.isPaid ? AppColors.success : AppColors.info,
                  size: 36,
                ),
            ],
          ),
          if (sub.paidAt != null) ...[
            const SizedBox(height: 6),
            Text(
              '${sub.isPaid ? "Paid" : "Settled"} on ${sub.paidAt!.day}/${sub.paidAt!.month}/${sub.paidAt!.year}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
          if (sub.isPending) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_empty, size: 16, color: AppColors.warning),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Payment submitted — waiting for admin confirmation.',
                      style: TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onPay != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Pay Platform Fee'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sub.status == 'overdue'
                      ? AppColors.error : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Color _statusColor(String s) {
    switch (s) {
      case 'paid':            return AppColors.success;
      case 'waived':          return AppColors.info;
      case 'pending_payment': return AppColors.warning;
      case 'overdue':         return AppColors.error;
      default:                return AppColors.warning;
    }
  }

  static String _monthFull(String my) {
    final p = my.split('-');
    const n = ['', 'January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'];
    return '${n[int.parse(p[1])]} ${p[0]}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pay-fee bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PaySheet extends StatefulWidget {
  final DriverPlatformSubscription sub;
  const _PaySheet({required this.sub});

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  static const _banks = {
    'CBE':      '1000123456789',
    'Awash':    '01320123456789',
    'Dashen':   '0090123456789',
    'BoA':      '70000123456789',
    'Telebirr': '0912345678',
  };

  String? _bank;
  final _refCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _copied = false;

  @override
  void dispose() {
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<DriverBillingProvider>();
    try {
      await p.submitPlatformFeePayment(
        subscriptionId: widget.sub.id,
        paymentRef: _refCtrl.text.trim(),
        paymentBank: _bank!,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Payment proof submitted. Admin will confirm soon.'),
        backgroundColor: AppColors.success,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = _bank != null ? _banks[_bank!] : null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Pay Platform Fee',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                'Transfer ${widget.sub.fee.toStringAsFixed(0)} ETB to UGO\'s bank account, then enter the transaction reference.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              // Amount chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount Due',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text('${widget.sub.fee.toStringAsFixed(0)} ETB',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Step 1
              const Text('Step 1 — Select Bank',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _banks.keys.map((b) {
                  final sel = _bank == b;
                  return ChoiceChip(
                    label: Text(b),
                    selected: sel,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500),
                    onSelected: (_) => setState(() => _bank = b),
                  );
                }).toList(),
              ),
              // Step 2
              if (account != null) ...[
                const SizedBox(height: 20),
                const Text('Step 2 — Transfer to this account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$_bank — UGO Platform',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                            Text(account,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _copied ? Icons.check : Icons.copy,
                          color: _copied ? AppColors.success : AppColors.primary,
                        ),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: account));
                          setState(() => _copied = true);
                          await Future.delayed(const Duration(seconds: 2));
                          if (mounted) setState(() => _copied = false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
              // Step 3
              const SizedBox(height: 20),
              const Text('Step 3 — Enter Transaction Reference',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _refCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. TXN123456789',
                  prefixIcon: const Icon(Icons.receipt_long_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Enter the transaction reference'
                        : null,
              ),
              const SizedBox(height: 24),
              Consumer<DriverBillingProvider>(
                builder: (_, p, __) => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_bank != null && !p.submitting) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: p.submitting
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Submit Payment Proof',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class _RetryView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _RetryView(this.error, this.onRetry);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  const _ErrorBanner(this.error);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Text(error,
          style: const TextStyle(color: AppColors.error, fontSize: 13)),
    );
  }
}
