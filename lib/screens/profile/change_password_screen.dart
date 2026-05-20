import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_newCtrl.text.length < 6) {
      _snack('New password must be at least 6 characters', AppColors.error);
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      _snack('Passwords do not match', AppColors.error);
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );
    if (success && mounted) {
      _snack('Password changed successfully!', AppColors.success);
      context.pop();
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.outfit()),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Change Password', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 18)),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.hPad),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _field(_currentCtrl, 'Current Password'),
                  const SizedBox(height: 16),
                  _field(_newCtrl, 'New Password'),
                  const SizedBox(height: 16),
                  _field(_confirmCtrl, 'Confirm New Password'),
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
                    onTap: auth.isLoading ? null : _save,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: auth.isLoading ? null : AppColors.primaryGradient,
                        color: auth.isLoading ? AppColors.disabled : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: auth.isLoading ? null : [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 5))],
                      ),
                      child: Center(
                        child: auth.isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Update Password', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
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
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      obscureText: _obscure,
      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
        suffixIcon: label == 'Current Password'
            ? GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textHint, size: 20),
                ),
              )
            : null,
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



