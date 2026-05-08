import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_button.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String purpose;
  const OtpScreen({super.key, required this.phone, required this.purpose});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the 6-digit OTP')));
      return;
    }
    final auth = context.read<AuthProvider>();
    if (widget.purpose == 'reset_password') {
      context.push('/reset-password', extra: {'phone': widget.phone, 'otp': _otp});
      return;
    }
    final success = await auth.verifyOtp(phone: widget.phone, otp: _otp, purpose: widget.purpose);
    if (success && mounted) {
      final status = auth.user?.status;
      context.go(status == 'pending' ? '/pending-approval' : '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hPad = context.hPad;
    final boxW = context.rv(40.0, 48.0, 56.0);
    final boxH = context.rv(48.0, 56.0, 64.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.sms_outlined, size: context.rv(42.0, 52.0, 60.0), color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: context.fsHeadline,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to\n${widget.phone}',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: context.fsBody),
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => SizedBox(
                  width: boxW,
                  height: boxH,
                  child: TextFormField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    style: TextStyle(fontSize: context.rv(20.0, 22.0, 24.0), fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                      if (i == 5 && v.isNotEmpty) _verify();
                    },
                  ),
                )),
              ),

              if (auth.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  auth.errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),
              AppButton(label: 'Verify OTP', isLoading: auth.isLoading, onPressed: _verify),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.read<AuthProvider>().resendOtp(
                    phone: widget.phone,
                    purpose: widget.purpose,
                  ),
                  child: const Text('Resend OTP', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
