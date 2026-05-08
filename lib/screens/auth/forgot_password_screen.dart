import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_phoneCtrl.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(_phoneCtrl.text.trim());
    if (success && mounted) {
      context.push('/otp', extra: {
        'phone': auth.pendingPhone ?? _phoneCtrl.text.trim(),
        'purpose': 'reset_password',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: AppColors.textPrimary, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_reset, size: context.rv(42.0, 52.0, 60.0), color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Forgot Password?',
                style: TextStyle(fontSize: context.fsHeadline, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number and we\'ll send you a verification code.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: context.fsBody),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(auth.errorMessage!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 24),
              AppButton(label: 'Send OTP', isLoading: auth.isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
