import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Text(l.underReview,
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    l.pendingReviewMessage,
                    style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, height: 1.7),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                _StepItem(step: '1', label: l.registrationSubmitted, done: true),
                const SizedBox(height: 12),
                _StepItem(step: '2', label: l.documentVerificationInProgress, done: false),
                const SizedBox(height: 12),
                _StepItem(step: '3', label: l.accountActivation, done: false, pending: true),

                if (auth.user != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.user!.fullName,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(auth.user!.phone,
                                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () async {
                    await auth.logout();
                    if (context.mounted) context.go('/login');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(l.signOut,
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String step;
  final String label;
  final bool done;
  final bool pending;

  const _StepItem({required this.step, required this.label, required this.done, this.pending = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: done ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: done ? 0.4 : 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: done ? AppColors.accent : Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : Center(
                    child: Text(step,
                      style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
              style: GoogleFonts.outfit(
                color: done ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              )),
          ),
          if (!done && !pending)
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.5))),
            ),
        ],
      ),
    );
  }
}
