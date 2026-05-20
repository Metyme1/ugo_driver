import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String purpose;
  const OtpScreen({super.key, required this.phone, required this.purpose});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  final _controllers = List.generate(_otpLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_otpLength, (_) => FocusNode());

  int _resendSeconds = 60;
  bool _canResend = false;
  Timer? _timer;

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _startTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_resendSeconds > 0) { _resendSeconds--; }
        else { _canResend = true; timer.cancel(); }
      });
    });
  }

  void _clearOtp() {
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
  }

  String _formatPhone(String phone) {
    if (phone.startsWith('+251') && phone.length >= 13) {
      return '${phone.substring(0, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
    }
    return phone;
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) _focusNodes[index + 1].requestFocus();
    setState(() {});
    if (_otp.length == _otpLength) _verify();
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_otp.length != _otpLength) return;

    if (widget.purpose == 'reset_password') {
      context.push('/reset-password', extra: {'phone': widget.phone, 'otp': _otp});
      return;
    }

    final auth = context.read<AuthProvider>();
    auth.clearError();
    final success = await auth.verifyOtp(phone: widget.phone, otp: _otp, purpose: widget.purpose);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Phone verified successfully!', style: GoogleFonts.outfit()),
        backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      final status = auth.user?.status;
      context.go(status == 'pending' ? '/pending-approval' : '/home');
    } else {
      _clearOtp();
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final success = await auth.resendOtp(phone: widget.phone, purpose: widget.purpose);
    if (!mounted) return;
    if (success) {
      _startTimer();
      _clearOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

              // Header
              const SizedBox(height: 16),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                ),
                child: const Icon(Icons.lock_outline_rounded, size: 34, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text('OTP Verification',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.3)),
              const SizedBox(height: 8),
              Text('Code sent to', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_formatPhone(widget.phone),
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 28),

              // White card
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text('Enter 6-digit code',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
                        const SizedBox(height: 20),

                        // OTP boxes
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: List.generate(_otpLength, (i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: KeyboardListener(
                                  focusNode: FocusNode(),
                                  onKeyEvent: (e) => _onKeyEvent(e, i),
                                  child: SizedBox(
                                    width: 52, height: 58,
                                    child: TextFormField(
                                      controller: _controllers[i],
                                      focusNode: _focusNodes[i],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      style: GoogleFonts.outfit(
                                        fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.primary),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        filled: true,
                                        fillColor: AppColors.inputFill,
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
                                        ),
                                      ),
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      onChanged: (v) => _onOtpChanged(v, i),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(auth.errorMessage!,
                              style: GoogleFonts.outfit(color: AppColors.error, fontSize: 13),
                              textAlign: TextAlign.center),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Verify button
                        GestureDetector(
                          onTap: auth.isLoading ? null : _verify,
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
                                  ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Verify Code',
                                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text("Didn't receive the code?",
                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 10),

                        GestureDetector(
                          onTap: _canResend ? _resend : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: _canResend ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _canResend ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
                            ),
                            child: Text(
                              _canResend ? 'Resend Code' : 'Retry in ${_resendSeconds}s',
                              style: GoogleFonts.outfit(
                                color: _canResend ? AppColors.primary : AppColors.textHint,
                                fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text('Change phone number',
                            style: GoogleFonts.outfit(
                              color: AppColors.textHint, fontSize: 12,
                              decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

