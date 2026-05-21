import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _currentCtrl  = TextEditingController();
  final _newCtrl      = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  static const int _otpLen = 6;
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes  = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 60;
  bool _canResend    = false;
  Timer? _timer;

  int _step = 1;
  late AnimationController _anim;
  late Animation<double> _fade;

  String get _otp => _otpControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes)  { f.dispose(); }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final l = AppLocalizations.of(context)!;
    if (_newCtrl.text.length < 8) { _snack(l.newPasswordTooShort, AppColors.error); return; }
    if (_newCtrl.text != _confirmCtrl.text) { _snack(l.passwordsDoNotMatch, AppColors.error); return; }
    context.read<AuthProvider>().clearError();
    final success = await context.read<AuthProvider>().requestChangePasswordOtp(
      currentPassword: _currentCtrl.text,
      newPassword:     _newCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );
    if (!mounted) return;
    if (success) _goToStep2();
  }

  void _goToStep2() {
    setState(() => _step = 2);
    _anim.reset(); _anim.forward();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _otpFocusNodes[0].requestFocus());
  }

  void _startTimer() {
    _resendSeconds = 60; _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendSeconds > 0) { _resendSeconds--; } else { _canResend = true; t.cancel(); }
      });
    });
  }

  void _clearOtp() {
    for (final c in _otpControllers) { c.clear(); }
    _otpFocusNodes[0].requestFocus();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < _otpLen - 1) _otpFocusNodes[index + 1].requestFocus();
    setState(() {});
    if (_otp.length == _otpLen) _confirmOtp();
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_otpControllers[index].text.isEmpty && index > 0) _otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _confirmOtp() async {
    if (_otp.length != _otpLen) return;
    final l = AppLocalizations.of(context)!;
    context.read<AuthProvider>().clearError();
    final success = await context.read<AuthProvider>().changePassword(_otp);
    if (!mounted) return;
    if (success) {
      _snack(l.passwordChangedSuccessfully, AppColors.success);
      context.pop();
    } else {
      _clearOtp();
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    context.read<AuthProvider>().clearError();
    final success = await context.read<AuthProvider>().requestChangePasswordOtp(
      currentPassword: _currentCtrl.text,
      newPassword:     _newCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );
    if (!mounted) return;
    if (success) { _startTimer(); _clearOtp(); }
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_step == 1 ? l.changePassword : l.verifyOtpTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 18)),
        leading: GestureDetector(
          onTap: () {
            if (_step == 2) { setState(() => _step = 1); _anim.reset(); _anim.forward(); _timer?.cancel(); }
            else { context.pop(); }
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 15),
          ),
        ),
      ),
      body: FadeTransition(opacity: _fade, child: _step == 1 ? _buildStep1(l) : _buildStep2(l)),
    );
  }

  Widget _buildStep1(AppLocalizations l) {
    final auth = context.watch<AuthProvider>();
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(l.changePasswordInfo, style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel(l.currentPasswordSection, AppColors.primary),
          const SizedBox(height: 10),
          _pwCard([_pwField(_currentCtrl, l.currentPassword, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent))]),
          const SizedBox(height: 16),
          _sectionLabel(l.newPasswordSection, const Color(0xFF7C3AED)),
          const SizedBox(height: 10),
          _pwCard([
            _pwField(_newCtrl, l.newPassword, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            const SizedBox(height: 14),
            _pwField(_confirmCtrl, l.confirmNewPassword, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
          ]),
          if (auth.errorMessage != null) ...[const SizedBox(height: 16), _errorBanner(auth.errorMessage!)],
          const SizedBox(height: 24),
          _primaryButton(label: l.sendOtp, icon: Icons.send_rounded, loading: auth.isLoading, onTap: _sendOtp),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep2(AppLocalizations l) {
    final auth = context.watch<AuthProvider>();
    final phone = context.read<AuthProvider>().user?.phone ?? '';
    final maskedPhone = phone.length >= 6 ? '${phone.substring(0, phone.length - 4)}****' : phone;

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(l.otpSentTo(maskedPhone), style: GoogleFonts.outfit(color: AppColors.success, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _sectionLabel(l.verificationCodeSection, const Color(0xFF7C3AED)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Text(l.enter6DigitCode, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: List.generate(_otpLen, (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (e) => _onKeyEvent(e, i),
                        child: SizedBox(
                          width: 50, height: 56,
                          child: TextFormField(
                            controller: _otpControllers[i],
                            focusNode: _otpFocusNodes[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true, fillColor: AppColors.inputFill,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2.5)),
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (v) => _onOtpChanged(v, i),
                          ),
                        ),
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _canResend ? _resend : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _canResend ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _canResend ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
                    ),
                    child: Text(
                      _canResend ? l.resendOtp : l.retryInSeconds(_resendSeconds),
                      style: GoogleFonts.outfit(color: _canResend ? AppColors.primary : AppColors.textHint, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (auth.errorMessage != null) ...[const SizedBox(height: 16), _errorBanner(auth.errorMessage!)],
          const SizedBox(height: 24),
          _primaryButton(label: l.confirm, icon: Icons.check_rounded, loading: auth.isLoading, onTap: _otp.length == _otpLen ? _confirmOtp : null, enabled: _otp.length == _otpLen),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title, Color color) {
    return Row(
      children: [
        Container(width: 3, height: 13, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _pwCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
    ),
    child: Column(children: children),
  );

  Widget _pwField(TextEditingController ctrl, String label, bool obscure, VoidCallback toggle) {
    return TextFormField(
      controller: ctrl, obscureText: obscure,
      style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Padding(padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(Icons.lock_outline_rounded, color: AppColors.primary.withValues(alpha: 0.5), size: 20)),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: GestureDetector(onTap: toggle,
          child: Padding(padding: const EdgeInsets.only(right: 14),
            child: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textHint, size: 20))),
        suffixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true, fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _errorBanner(String message) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(message, style: GoogleFonts.outfit(color: AppColors.error, fontSize: 13))),
    ]),
  );

  Widget _primaryButton({required String label, required IconData icon, required bool loading, required VoidCallback? onTap, bool enabled = true}) {
    final active = enabled && !loading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          color: active ? null : AppColors.disabled,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 5))] : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                  ],
                ),
        ),
      ),
    );
  }
}
