import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/driver_billing_model.dart';
import '../../providers/driver_billing_provider.dart';

// â”€â”€â”€ Shared date helper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const _monthNamesFull = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _monthNamesShort = [
  '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtShortDate(DateTime d) => '${_monthNamesShort[d.month]} ${d.day}, ${d.year}';
String _fmtFullDate(DateTime d) => '${_monthNamesFull[d.month]} ${d.day}, ${d.year}';
String _dayKey(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

// â”€â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    _tabs = TabController(length: 4, vsync: this);
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
        title: Text(AppLocalizations.of(context)!.myEarnings,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        iconTheme: const IconThemeData(color: AppColors.primary),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.summary),
            Tab(text: AppLocalizations.of(context)!.daily),
            Tab(text: AppLocalizations.of(context)!.earnings),
            Tab(text: AppLocalizations.of(context)!.platformFee),
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
                _DailyEarningsTab(),
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Month selector
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
          decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColors.border))), padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                onPressed: idx > 0 ? () => p.selectMonth(_months[idx - 1]) : null,
              ),
              Text(
                _label(p.selectedMonth),
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.primary),
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// TAB 1 â€” Summary
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                const _WalletOverviewCard(),
                const SizedBox(height: 12),
                _BreakdownCard(summary: s),
                const SizedBox(height: 12),
                _ActivityRow(summary: s),
                const SizedBox(height: 12),
                _PayoutCard(summary: s, wallet: p.walletOverview),
              ],
            ),
          ),
        );
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Wallet overview â€” lifetime balance breakdown by income source
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WalletOverviewCard extends StatelessWidget {
  const _WalletOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverBillingProvider>(
      builder: (_, p, __) {
        final w = p.walletOverview ?? DriverWalletOverview.empty();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Row(children: [
                Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text('Your Wallet', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
              ]),
            ),
            _WalletSourceCard(
              label: 'Total Income',
              sub: 'All-time earnings on UGO — every source combined',
              amount: w.totalIncome,
              color: AppColors.primary,
              icon: Icons.savings_outlined,
            ),
            const SizedBox(height: 12),
            _WalletSourceCard(
              label: 'Available Now',
              sub: 'Withdraw instantly — from packages scanned: ETB ${w.unwithdrawnPackageBalance.toStringAsFixed(0)}',
              amount: w.availableBalance,
              color: AppColors.success,
              icon: Icons.bolt_outlined,
            ),
            const SizedBox(height: 12),
            _WalletSourceCard(
              label: 'Pending from Subscriptions',
              sub: w.nextReleaseDate != null
                  ? 'Locked until ${_fmtShortDate(w.nextReleaseDate!)} — or request an early payout below'
                  : 'Released once each contract period ends',
              amount: w.pendingSubscriptionBalance,
              color: AppColors.warning,
              icon: Icons.lock_clock_outlined,
              child: w.pendingBySubscription.isEmpty
                  ? null
                  : Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 14, bottom: 8),
                          child: Divider(color: AppColors.border, height: 1),
                        ),
                        ...w.pendingBySubscription.map((sub) => _PendingSubscriptionRow(payout: sub)),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// A standalone card representing one income source on the driver's wallet —
/// keeps "instant" (packages), "locked" (subscriptions) and lifetime totals
/// visually distinct rather than rows within a single shared card.
class _WalletSourceCard extends StatelessWidget {
  final String label;
  final String sub;
  final double amount;
  final Color color;
  final IconData icon;
  final Widget? child;
  const _WalletSourceCard({
    required this.label,
    required this.sub,
    required this.amount,
    required this.color,
    required this.icon,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text('ETB ${amount.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color)),
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ),
            ],
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _PendingSubscriptionRow extends StatelessWidget {
  final PendingSubscriptionPayout payout;
  const _PendingSubscriptionRow({required this.payout});

  @override
  Widget build(BuildContext context) {
    final date = payout.scheduledReleaseDate != null
        ? _fmtShortDate(payout.scheduledReleaseDate!)
        : 'â€”';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payout.groupName ?? 'Subscription contract',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text('ETB ${payout.amount.toStringAsFixed(0)}  â€¢  available $date',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _EarlyReleaseAction(payout: payout),
        ],
      ),
    );
  }
}

class _EarlyReleaseAction extends StatelessWidget {
  final PendingSubscriptionPayout payout;
  const _EarlyReleaseAction({required this.payout});

  @override
  Widget build(BuildContext context) {
    if (payout.hasOpenRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: const Text('Requested',
            style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w500)),
      );
    }
    if (!payout.canRequestEarlyRelease) return const SizedBox.shrink();
    return TextButton(
      onPressed: () => _openSheet(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('Request early payout',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.warning)),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EarlyReleaseRequestSheet(payout: payout),
    );
  }
}

class _EarlyReleaseRequestSheet extends StatefulWidget {
  final PendingSubscriptionPayout payout;
  const _EarlyReleaseRequestSheet({required this.payout});

  @override
  State<_EarlyReleaseRequestSheet> createState() => _EarlyReleaseRequestSheetState();
}

class _EarlyReleaseRequestSheetState extends State<_EarlyReleaseRequestSheet> {
  final _noteCtrl = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _submitting = true; _error = null; });
    final provider = context.read<DriverBillingProvider>();
    try {
      await provider.submitEarlyReleaseRequest(widget.payout.subscriptionId, note: _noteCtrl.text.trim());
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.payout.scheduledReleaseDate != null
        ? _fmtFullDate(widget.payout.scheduledReleaseDate!)
        : 'the contract end date';

    if (_submitted) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.hourglass_top_rounded, color: AppColors.info, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Request Submitted', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text(
              'UGO will review your request to end this subscription contract early. '
              "You'll be notified once it's approved and the funds are released.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Request Early Payout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            '${widget.payout.groupName ?? "This subscription"} â€” ETB ${widget.payout.amount.toStringAsFixed(0)} held until $date',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Requesting an early payout means agreeing to end your contract on this route â€” UGO will reassign it to another driver. This cannot be undone once approved.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Reason (optional)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Let UGO know why you need this payout early',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(_submitting ? 'Submitting...' : 'Submit Request',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
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
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.account_balance_wallet, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(l.revenueBreakdown, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                ]),
                const SizedBox(height: 20),
                _BRow(label: l.grossRevenue, sub: l.fromParents, amount: summary.grossTotal, color: AppColors.info, icon: Icons.arrow_downward),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: AppColors.border)),
                _BRow(label: l.ugoCommission, sub: l.platformFeePercent, amount: summary.ugoCommissionTotal, color: AppColors.warning, icon: Icons.remove, negative: true),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: AppColors.border, thickness: 2)),
                _BRow(label: l.yourNetEarnings, sub: l.beforePlatformSub, amount: summary.netEarnings, color: AppColors.success, icon: Icons.check_circle_outline, large: true),
              ],
            );
          }),
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
                      fontWeight: large ? FontWeight.w500 : FontWeight.w500,
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
              fontWeight: FontWeight.w500,
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
        Builder(builder: (context) {
          final l = AppLocalizations.of(context)!;
          return Expanded(child: _StatBox(icon: Icons.directions_car_outlined, value: '${summary.tripCount}', label: l.tripsDone, color: AppColors.primary));
        }),
        const SizedBox(width: 12),
        Builder(builder: (context) {
          final l = AppLocalizations.of(context)!;
          return Expanded(child: _StatBox(icon: Icons.receipt_long_outlined, value: '${summary.subscriptionCount}', label: l.subscriptions, color: AppColors.secondary));
        }),
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: color)),
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
  final DriverWalletOverview? wallet;
  const _PayoutCard({required this.summary, this.wallet});

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
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.payments_outlined, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(l.estimatedPayout, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                ]),
                const SizedBox(height: 16),
                Text('${summary.estimatedPayout.toStringAsFixed(0)} ETB',
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w500, color: AppColors.success)),
                Text(l.takeHomeThisMonth, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            );
          }),
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
                    Builder(builder: (context) => Text(AppLocalizations.of(context)!.platformSubscription,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
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
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 8),
                        Text('- ${summary.driverPlatformFee.toStringAsFixed(0)} ETB',
                            style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w400,
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
                // Platform Fee is now tab index 3
                onPressed: () => DefaultTabController.of(context).animateTo(3),
                icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                label: Builder(builder: (context) => Text(AppLocalizations.of(context)!.payPlatformFee,
                    style: const TextStyle(color: AppColors.warning))),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.warning)),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (wallet?.availableBalance ?? 0) > 0
                  ? () => context.push('/billing/withdraw',
                        extra: wallet!.availableBalance)
                  : null,
              icon: const Icon(Icons.account_balance_outlined, size: 18),
              label: const Text('Withdraw Funds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
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
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// TAB 2 â€” Daily earnings (package + subscription toggle with calendar)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DailyEarningsTab extends StatefulWidget {
  const _DailyEarningsTab();

  @override
  State<_DailyEarningsTab> createState() => _DailyEarningsTabState();
}

class _DailyEarningsTabState extends State<_DailyEarningsTab> {
  bool _showPackage = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverBillingProvider>(
      builder: (_, p, __) {
        if (p.earningsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final packageRecs = p.earnings
            .where((e) => e.type == 'ride_package_earning')
            .toList();
        final subRecs = p.earnings
            .where((e) => e.type == 'trip_earning')
            .toList();

        final packageTotal = packageRecs.fold(0.0, (s, r) => s + r.netAmount);
        final subTotal = subRecs.fold(0.0, (s, r) => s + r.netAmount);

        final currentRecs = _showPackage ? packageRecs : subRecs;
        final byDay = <String, List<DriverEarningRecord>>{};
        for (final r in currentRecs) {
          if (r.earnedAt == null) continue;
          (byDay[_dayKey(r.earnedAt!)] ??= []).add(r);
        }

        final parts = p.selectedMonth.split('-');
        final calMonth =
            DateTime(int.parse(parts[0]), int.parse(parts[1]));

        return RefreshIndicator(
          onRefresh: p.loadEarnings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (p.earningsError != null) _ErrorBanner(p.earningsError!),
                _DailySummaryBar(
                  packageTotal: packageTotal,
                  subTotal: subTotal,
                ),
                const SizedBox(height: 14),
                _EarningsToggle(
                  showPackage: _showPackage,
                  packageTotal: packageTotal,
                  subTotal: subTotal,
                  onToggle: (v) => setState(() => _showPackage = v),
                ),
                const SizedBox(height: 14),
                _EarningsCalendar(
                  month: calMonth,
                  byDay: byDay,
                  isPackage: _showPackage,
                  onDateTapped: (date) {
                    final dayEarnings = byDay[_dayKey(date)] ?? [];
                    _showDayDetail(context, date, dayEarnings, _showPackage, p);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDayDetail(
    BuildContext context,
    DateTime date,
    List<DriverEarningRecord> dayEarnings,
    bool isPackage,
    DriverBillingProvider p,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => isPackage
          ? _PackageDaySheet(date: date, earnings: dayEarnings)
          : _SubDaySheet(date: date, earnings: dayEarnings, provider: p),
    );
  }
}

// â”€â”€ Daily summary bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DailySummaryBar extends StatelessWidget {
  final double packageTotal;
  final double subTotal;

  const _DailySummaryBar({
    required this.packageTotal,
    required this.subTotal,
  });

  @override
  Widget build(BuildContext context) {
    final combined = packageTotal + subTotal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Builder(builder: (context) => Text(AppLocalizations.of(context)!.totalEarnedThisMonth,
              style: const TextStyle(color: Colors.white70, fontSize: 12))),
          const SizedBox(height: 4),
          Text(
            'ETB ${combined.toStringAsFixed(0)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryMini(
                  label: 'Packages',
                  amount: packageTotal,
                  icon: Icons.qr_code_scanner,
                ),
              ),
              Container(width: 1, height: 36, color: Colors.white30),
              Expanded(
                child: _SummaryMini(
                  label: 'Subscription',
                  amount: subTotal,
                  icon: Icons.directions_bus_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMini extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;

  const _SummaryMini({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          'ETB ${amount.toStringAsFixed(0)}',
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}

// â”€â”€ Toggle chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EarningsToggle extends StatelessWidget {
  final bool showPackage;
  final double packageTotal;
  final double subTotal;
  final void Function(bool) onToggle;

  const _EarningsToggle({
    required this.showPackage,
    required this.packageTotal,
    required this.subTotal,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _ToggleBtn(label: l.packageEarnings, icon: Icons.qr_code_scanner, amount: packageTotal, selected: showPackage, color: AppColors.primary, onTap: () => onToggle(true));
          }),
          Builder(builder: (context) {
            final l = AppLocalizations.of(context)!;
            return _ToggleBtn(label: l.subscriptions, icon: Icons.route_outlined, amount: subTotal, selected: !showPackage, color: AppColors.success, onTap: () => onToggle(false));
          }),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final double amount;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.icon,
    required this.amount,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : AppColors.textHint),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: selected ? Colors.white : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400)),
                  Text('ETB ${amount.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: selected ? Colors.white70 : AppColors.textHint,
                          fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Earnings calendar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EarningsCalendar extends StatelessWidget {
  final DateTime month;
  final Map<String, List<DriverEarningRecord>> byDay;
  final bool isPackage;
  final void Function(DateTime) onDateTapped;

  const _EarningsCalendar({
    required this.month,
    required this.byDay,
    required this.isPackage,
    required this.onDateTapped,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final color = isPackage ? AppColors.primary : AppColors.success;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPackage ? Icons.qr_code_scanner : Icons.route_outlined,
                    color: color, size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPackage ? 'Package Earnings' : 'Subscription Earnings',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary),
                      ),
                      Text(
                        '${_monthNamesFull[month.month]} ${month.year}  Â·  Tap a day for details',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textHint)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 4),
                _buildGrid(now, daysInMonth, firstWeekday, color),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Has earnings',
                    style: TextStyle(fontSize: 10, color: AppColors.textHint)),
                const SizedBox(width: 12),
                const Icon(Icons.touch_app_outlined, size: 10, color: AppColors.textHint),
                const SizedBox(width: 4),
                const Text('Tap for details',
                    style: TextStyle(fontSize: 10, color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
      DateTime now, int daysInMonth, int firstWeekday, Color color) {
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final cells = <Widget>[];

    for (var i = 0; i < rows * 7; i++) {
      final dayNum = i - firstWeekday + 1;
      if (dayNum < 1 || dayNum > daysInMonth) {
        cells.add(const Expanded(child: SizedBox()));
        continue;
      }

      final thisDate = DateTime(month.year, month.month, dayNum);
      final isToday = dayNum == now.day &&
          month.month == now.month &&
          month.year == now.year;
      final key = _dayKey(thisDate);
      final hasEarnings = (byDay[key] ?? []).isNotEmpty;

      cells.add(Expanded(
        child: GestureDetector(
          onTap: () => onDateTapped(thisDate),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: isToday
                    ? color
                    : hasEarnings
                        ? color.withValues(alpha: 0.1)
                        : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday || hasEarnings
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: isToday
                          ? Colors.white
                          : hasEarnings
                              ? color
                              : AppColors.textPrimary,
                    ),
                  ),
                  if (hasEarnings && !isToday)
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 4, height: 4,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ));
    }

    final rowWidgets = <Widget>[];
    for (var r = 0; r < rows; r++) {
      rowWidgets.add(Row(children: cells.sublist(r * 7, (r + 1) * 7)));
    }
    return Column(children: rowWidgets);
  }
}

// â”€â”€ Package day detail sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PackageDaySheet extends StatelessWidget {
  final DateTime date;
  final List<DriverEarningRecord> earnings;

  const _PackageDaySheet({required this.date, required this.earnings});

  @override
  Widget build(BuildContext context) {
    final total = earnings.fold(0.0, (s, r) => s + r.netAmount);
    final gross = earnings.fold(0.0, (s, r) => s + r.grossAmount);
    final commission = earnings.fold(0.0, (s, r) => s + r.ugoCommission);
    final isEmpty = earnings.isEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_scanner,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fmtFullDate(date),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  Text(
                    '${earnings.length} package${earnings.length == 1 ? '' : 's'} scanned',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12)),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_2, size: 36, color: AppColors.textHint),
                  SizedBox(height: 8),
                  Text('No packages scanned on this day',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary)),
                ],
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Day's Package Earnings",
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                        Text('ETB ${total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary)),
                        Text(
                          'Gross: ${gross.toStringAsFixed(0)}  -  Commission: ${commission.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${earnings.length}\nscans',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppColors.primary,
                          height: 1.2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Scanned Packages',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ...earnings.map((r) => _PackageScanRow(record: r)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openWithdrawSheet(context, total, date);
                },
                icon: const Icon(Icons.account_balance_wallet_outlined,
                    size: 18),
                label:
                    Text('Withdraw  ETB ${total.toStringAsFixed(0)}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openWithdrawSheet(BuildContext context, double amount, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _WithdrawSheet(amount: amount, date: date),
    );
  }
}

class _PackageScanRow extends StatelessWidget {
  final DriverEarningRecord record;
  const _PackageScanRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final time = record.earnedAt != null
        ? '${record.earnedAt!.hour.toString().padLeft(2, '0')}:${record.earnedAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.groupName ?? record.description ?? 'Package scan',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                ),
                if (time.isNotEmpty)
                  Text(time,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          Text(
            '+ETB ${record.netAmount.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Subscription day detail sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SubDaySheet extends StatelessWidget {
  final DateTime date;
  final List<DriverEarningRecord> earnings;
  final DriverBillingProvider provider;

  const _SubDaySheet({
    required this.date,
    required this.earnings,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final total = earnings.fold(0.0, (s, r) => s + r.netAmount);
    final gross = earnings.fold(0.0, (s, r) => s + r.grossAmount);
    final commission = earnings.fold(0.0, (s, r) => s + r.ugoCommission);
    final isEmpty = earnings.isEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route_outlined,
                    color: AppColors.success, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fmtFullDate(date),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  Text(
                    '${earnings.length} route${earnings.length == 1 ? '' : 's'} completed',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12)),
              child: const Column(
                children: [
                  Icon(Icons.route, size: 36, color: AppColors.textHint),
                  SizedBox(height: 8),
                  Text('No subscription routes on this day',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary)),
                ],
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Day's Route Earnings",
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                        Text('ETB ${total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success)),
                        Text(
                          'Gross: ${gross.toStringAsFixed(0)}  -  Commission: ${commission.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${earnings.length}\nroutes',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppColors.success,
                          height: 1.2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Routes Completed',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ...earnings.map((r) => _SubRouteRow(record: r)),
          ],
          const SizedBox(height: 16),
          _PaymentWindowCard(
            monthYear: provider.selectedMonth,
            platformStatus:
                provider.currentMonthPlatformSub?.status ?? 'none',
            feeAmount:
                provider.currentMonthPlatformSub?.fee ?? 0,
            estimatedPayout: provider.summary?.estimatedPayout ?? 0,
          ),
        ],
      ),
    );
  }
}

class _SubRouteRow extends StatelessWidget {
  final DriverEarningRecord record;
  const _SubRouteRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final routeLabels = {
      'morning_to_school':   l.routeMorningToSchool,
      'midday_to_home':      l.routeMiddayToHome,
      'afternoon_to_school': l.routeAfternoonToSchool,
      'afternoon_to_home':   l.routeAfternoonToHome,
    };
    final routeLabel = routeLabels[record.routeType] ?? record.routeType ?? l.route;
    final time = record.earnedAt != null
        ? '${record.earnedAt!.hour.toString().padLeft(2, '0')}:${record.earnedAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.success.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.groupName ?? 'Group',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text('$routeLabel  $time',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          Text(
            '+ETB ${record.netAmount.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Payment window card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PaymentWindowCard extends StatelessWidget {
  final String monthYear;
  final String platformStatus;
  final double feeAmount;
  final double estimatedPayout;

  const _PaymentWindowCard({
    required this.monthYear,
    required this.platformStatus,
    required this.feeAmount,
    required this.estimatedPayout,
  });

  @override
  Widget build(BuildContext context) {
    final parts = monthYear.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    // Drivers are paid from the 1st to 5th of the following month
    final windowStart = DateTime(year, month + 1, 1);
    final windowEnd = DateTime(year, month + 1, 5);
    final now = DateTime.now();
    final isOpen = now.isAfter(windowStart) && now.isBefore(windowEnd);
    final isPast = now.isAfter(windowEnd);
    final daysUntil = windowStart.difference(now).inDays;

    final borderColor = isOpen
        ? AppColors.success.withValues(alpha: 0.3)
        : AppColors.border;
    final bgColor = isOpen
        ? AppColors.success.withValues(alpha: 0.07)
        : AppColors.background;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOpen ? Icons.payments_outlined : Icons.schedule,
                size: 16,
                color: isOpen ? AppColors.success : AppColors.textHint,
              ),
              const SizedBox(width: 6),
              Text(
                'Payment Window',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isOpen
                        ? AppColors.success
                        : AppColors.textPrimary),
              ),
              const Spacer(),
              if (isOpen)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('OPEN NOW',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${_monthNamesFull[month]} earnings are paid out:',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '${_fmtShortDate(windowStart)}  â€”  ${_fmtShortDate(windowEnd)}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isOpen
                    ? AppColors.success
                    : AppColors.textPrimary),
          ),
          if (!isOpen && !isPast && daysUntil >= 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Opens in $daysUntil day${daysUntil == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textHint),
              ),
            )
          else if (isPast)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Payment window for this period has closed.',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ),
          if (estimatedPayout > 0) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estimated payout',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  'ETB ${estimatedPayout.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success),
                ),
              ],
            ),
          ],
          if (platformStatus == 'due' || platformStatus == 'overdue') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 13, color: AppColors.warning),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Platform fee (ETB ${feeAmount.toStringAsFixed(0)}) will be deducted from payout.',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// â”€â”€ Withdraw sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WithdrawSheet extends StatefulWidget {
  final double amount;
  final DateTime date;

  const _WithdrawSheet({required this.amount, required this.date});

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  static const _banks = ['CBE', 'Awash', 'Dashen', 'BoA', 'Telebirr'];
  String? _bank;
  final _accountCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _accountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            const Text('Withdrawal Requested',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'ETB ${widget.amount.toStringAsFixed(0)} will be transferred to your $_bank account. '
              'Admin will process within 1â€“2 business days.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Withdraw Package Earnings',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            '${_fmtFullDate(widget.date)} earnings â€” transferred to your bank account.',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.success),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Withdrawal Amount',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    Text(
                      'ETB ${widget.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select Bank',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _banks.map((b) {
              final sel = _bank == b;
              return ChoiceChip(
                label: Text(b),
                selected: sel,
                selectedColor: AppColors.success,
                labelStyle: TextStyle(
                    color: sel ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500),
                onSelected: (_) => setState(() => _bank = b),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Account Number',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _accountCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Enter your bank account number',
              prefixIcon: const Icon(Icons.account_balance),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 14),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _bank != null &&
                      _accountCtrl.text.trim().isNotEmpty
                  ? () => setState(() => _submitted = true)
                  : null,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Request Withdrawal',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// TAB 3 â€” Earnings list
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  static Color _typeColor(String type) {
    switch (type) {
      case 'trip_earning':         return AppColors.primary;
      case 'university_ride':      return const Color(0xFF7C3AED);
      case 'ride_package_earning': return AppColors.success;
      default:                     return AppColors.secondary;
    }
  }

  static IconData _typeIcon(String type) {
    switch (type) {
      case 'trip_earning':         return Icons.directions_car_outlined;
      case 'university_ride':      return Icons.school_outlined;
      case 'ride_package_earning': return Icons.qr_code_scanner;
      default:                     return Icons.receipt_outlined;
    }
  }

  static String _typeTag(String type) {
    switch (type) {
      case 'trip_earning':         return 'TRIP';
      case 'university_ride':      return 'UNI';
      case 'ride_package_earning': return 'PKG';
      default:                     return 'SUB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = _typeColor(earning.type);
    final icon  = _typeIcon(earning.type);
    final isTrip = earning.type == 'trip_earning';
    final isUni  = earning.type == 'university_ride';
    final isPkg  = earning.type == 'ride_package_earning';
    final routeLabels = {
      'morning_to_school':   '${l.routeMorningToSchool}  07:00',
      'midday_to_home':      '${l.routeMiddayToHome}  12:00',
      'afternoon_to_school': '${l.routeAfternoonToSchool}  14:00',
      'afternoon_to_home':   '${l.routeAfternoonToHome}  16:30',
    };

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
                        style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
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
                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isUni
                      ? 'Boarding confirmed'
                      : isTrip
                          ? (routeLabels[earning.routeType] ?? earning.routeType ?? '')
                          : isPkg
                              ? l.packageScan
                              : l.subscriptions,
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
                fontWeight: FontWeight.w500,
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// TAB 4 â€” Platform Fee
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sc.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sc),
                ),
                child: Text(sl,
                    style: TextStyle(color: sc, fontSize: 11, fontWeight: FontWeight.w500)),
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
                            fontWeight: FontWeight.w500, fontSize: 24)),
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
                      'Payment submitted â€” waiting for admin confirmation.',
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
    return '${_monthNamesFull[int.parse(p[1])]} ${p[0]}';
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Pay-fee bottom sheet
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                'Transfer ${widget.sub.fee.toStringAsFixed(0)} ETB to UGO\'s bank account, then enter the transaction reference.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
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
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Step 1 â€” Select Bank',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
              if (account != null) ...[
                const SizedBox(height: 20),
                const Text('Step 2 â€” Transfer to this account',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
                      const Icon(Icons.account_balance,
                          color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$_bank â€” UGO Platform',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                            Text(account,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
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
              const SizedBox(height: 20),
              const Text('Step 3 â€” Enter Transaction Reference',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _refCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. TXN123456789',
                  prefixIcon: const Icon(Icons.receipt_long_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 14),
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
                                fontSize: 15, fontWeight: FontWeight.w500)),
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Shared helpers
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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




