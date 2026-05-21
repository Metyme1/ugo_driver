import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

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
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                  ),
                  child: const Icon(Icons.lock_reset_rounded, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(l.forgotPasswordTitle,
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.3)),
                const SizedBox(height: 6),
                Text(l.sendCodeToPhone,
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 36),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.phoneNumber,
                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: 0.3)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: '09XXXXXXXX',
                              hintStyle: GoogleFonts.outfit(color: AppColors.textHint),
                              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
                              filled: true, fillColor: AppColors.inputFill,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                            ),
                          ),
                          if (auth.errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                              ),
                              child: Text(auth.errorMessage!, style: GoogleFonts.outfit(color: AppColors.error, fontSize: 13)),
                            ),
                          ],
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: auth.isLoading ? null : _submit,
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: auth.isLoading ? null : AppColors.primaryGradient,
                                color: auth.isLoading ? AppColors.disabled : null,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: auth.isLoading ? null : [
                                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Center(
                                child: auth.isLoading
                                    ? const SizedBox(width: 22, height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : Text(l.sendOtp,
                                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
