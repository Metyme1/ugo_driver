import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  final String otp;
  const ResetPasswordScreen({super.key, required this.phone, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password must be at least 6 characters', style: GoogleFonts.outfit()),
        backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Passwords do not match', style: GoogleFonts.outfit()),
        backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(
      phone: widget.phone, otp: widget.otp,
      newPassword: _newCtrl.text, confirmPassword: _confirmCtrl.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset successfully!', style: GoogleFonts.outfit()),
        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 15),
          ),
        ),
        title: Text('New Password', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Password', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: 0.3)),
                  const SizedBox(height: 8),
                  _buildField(controller: _newCtrl, hint: 'Min 8 characters', obscure: _obscure,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textHint, size: 20))),
                  const SizedBox(height: 18),
                  Text('Confirm Password', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: 0.3)),
                  const SizedBox(height: 8),
                  _buildField(controller: _confirmCtrl, hint: 'Repeat password', obscure: _obscure),
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
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: auth.isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text('Reset Password', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
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

  Widget _buildField({required TextEditingController controller, required String hint, required bool obscure, Widget? suffix}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: AppColors.textHint),
        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
        suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix) : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        filled: true, fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}



