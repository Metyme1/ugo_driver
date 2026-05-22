import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/driver_billing_service.dart';

class WithdrawalScreen extends StatefulWidget {
  final double availableBalance;
  const WithdrawalScreen({super.key, required this.availableBalance});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _service = DriverBillingService(ApiService());
  final _formKey = GlobalKey<FormState>();

  final _accountNameCtrl   = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _amountCtrl        = TextEditingController();

  List<Map<String, dynamic>> _banks = [];
  Map<String, dynamic>? _selectedBank;
  bool _loadingBanks = true;
  bool _submitting   = false;
  String? _banksError;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    setState(() { _loadingBanks = true; _banksError = null; });
    try {
      final banks = await _service.getBanks();
      if (mounted) setState(() { _banks = banks; _loadingBanks = false; });
    } catch (e) {
      if (mounted) setState(() { _banksError = e.toString().replaceFirst('Exception: ', ''); _loadingBanks = false; });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank'), backgroundColor: AppColors.error),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount > widget.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Amount exceeds available balance (${widget.availableBalance.toStringAsFixed(0)} ETB)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final ref = await _service.requestWithdrawal(
        amount:        amount,
        bankCode:      _selectedBank!['id'].toString(),
        accountNumber: _accountNumberCtrl.text.trim(),
        accountName:   _accountNameCtrl.text.trim(),
      );
      if (!mounted) return;
      _showSuccessDialog(amount, ref);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog(double amount, String ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, size: 40, color: AppColors.success),
            ),
            const SizedBox(height: 16),
            const Text('Withdrawal Initiated!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(0)} ETB is being transferred to your account. Funds usually arrive within minutes.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: ref));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reference copied')));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ref, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textSecondary)),
                    const SizedBox(width: 6),
                    const Icon(Icons.copy, size: 14, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _loadingBanks
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _banksError != null
              ? _BanksError(error: _banksError!, onRetry: _loadBanks)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Available Balance',
                                style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text('${widget.availableBalance.toStringAsFixed(0)} ETB',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 32,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text('Estimated payout this month',
                                style: TextStyle(color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                      const Text('Bank Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 14),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Bank selector
                            _FieldWrapper(
                              label: 'Bank',
                              child: DropdownButtonFormField<Map<String, dynamic>>(
                                initialValue: _selectedBank,
                                hint: const Text('Select your bank',
                                    style: TextStyle(color: AppColors.textHint, fontSize: 14)),
                                items: _banks.map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(b['name'] as String? ?? '',
                                      style: const TextStyle(fontSize: 14)),
                                )).toList(),
                                onChanged: (v) => setState(() => _selectedBank = v),
                                decoration: const InputDecoration.collapsed(hintText: ''),
                                isExpanded: true,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Account name
                            _FieldWrapper(
                              label: 'Account Holder Name',
                              child: TextFormField(
                                controller: _accountNameCtrl,
                                decoration: const InputDecoration.collapsed(
                                    hintText: 'Name on the bank account'),
                                style: const TextStyle(fontSize: 14),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Account name is required' : null,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Account number
                            _FieldWrapper(
                              label: 'Account Number',
                              child: TextFormField(
                                controller: _accountNumberCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: const InputDecoration.collapsed(
                                    hintText: 'e.g. 1000123456789'),
                                style: const TextStyle(fontSize: 14, letterSpacing: 1),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Account number is required';
                                  if (v.trim().length < 8) return 'Enter a valid account number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Amount
                            _FieldWrapper(
                              label: 'Amount (ETB)',
                              child: TextFormField(
                                controller: _amountCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Max ${widget.availableBalance.toStringAsFixed(0)} ETB'),
                                style: const TextStyle(fontSize: 14),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                                  final a = double.tryParse(v.trim());
                                  if (a == null || a <= 0) return 'Enter a valid amount';
                                  if (a > widget.availableBalance) {
                                    return 'Cannot exceed ${widget.availableBalance.toStringAsFixed(0)} ETB';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Quick-fill buttons
                            Row(
                              children: [
                                _QuickFill(label: '25%', amount: widget.availableBalance * 0.25, onTap: (a) => _amountCtrl.text = a.toStringAsFixed(0)),
                                const SizedBox(width: 8),
                                _QuickFill(label: '50%', amount: widget.availableBalance * 0.5,  onTap: (a) => _amountCtrl.text = a.toStringAsFixed(0)),
                                const SizedBox(width: 8),
                                _QuickFill(label: '75%', amount: widget.availableBalance * 0.75, onTap: (a) => _amountCtrl.text = a.toStringAsFixed(0)),
                                const SizedBox(width: 8),
                                _QuickFill(label: 'All',  amount: widget.availableBalance,         onTap: (a) => _amountCtrl.text = a.toStringAsFixed(0)),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Warning box
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Funds are transferred via Chapa. Make sure your account details are correct — transfers cannot be reversed once sent.',
                                      style: TextStyle(fontSize: 12, color: Colors.orange, height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                ),
                                child: _submitting
                                    ? const SizedBox(width: 22, height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Text('Withdraw Funds',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

// ── Shared widgets ────────────────────────────────────────────────────────────

class _FieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldWrapper({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _QuickFill extends StatelessWidget {
  final String label;
  final double amount;
  final void Function(double) onTap;
  const _QuickFill({required this.label, required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ),
    );
  }
}

class _BanksError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _BanksError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
