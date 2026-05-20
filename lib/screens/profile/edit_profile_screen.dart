import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstCtrl.text   = user?.firstName ?? '';
    _lastCtrl.text    = user?.lastName ?? '';
    _emailCtrl.text   = user?.email ?? '';
    _addressCtrl.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose();
    _emailCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated!', style: GoogleFonts.outfit()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontSize: 18)),
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
                  _field(_firstCtrl, 'First Name', Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                  _field(_lastCtrl, 'Last Name', Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                  _field(_emailCtrl, 'Email (optional)', Icons.email_outlined, type: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _field(_addressCtrl, 'Address (optional)', Icons.location_on_outlined),
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
                                  const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Save Changes', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
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

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType? type}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
        filled: true, fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}



