import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      q: 'How do I start a route?',
      a: 'Go to the Routes tab and tap "Start" on the route you want to begin. Make sure you are at the pickup location before starting.'
    ),
    (
      q: 'What if a student is absent?',
      a: 'When running a route, tap the student\'s name and mark them as absent. The parent will be notified automatically.'
    ),
    (
      q: 'How are my earnings calculated?',
      a: 'Earnings are based on completed trips and your contract rate. You can view a full breakdown in the Earnings section of your profile.'
    ),
    (
      q: 'What do I do if my vehicle breaks down?',
      a: 'Contact UGO support immediately using the number below. Inform parents of the delay through the app by pausing the route.'
    ),
    (
      q: 'How do I scan a student\'s QR code?',
      a: 'Tap the scan icon on the home screen or routes screen. Hold the camera over the student\'s QR code to record their pickup or drop-off.'
    ),
    (
      q: 'Can I decline a group nomination?',
      a: 'Yes. Open the Nominations tab, select the group, and tap "Decline". You can provide an optional reason.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Help & Support',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 18)),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UGO Driver Support',
                          style: GoogleFonts.outfit(
                            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text('Available 7 days a week, 6 AM – 8 PM',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            _ContactChip(icon: Icons.phone_rounded, label: '+251 911 000 000'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _sectionLabel('FREQUENTLY ASKED QUESTIONS', AppColors.primary),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: _faqs.asMap().entries.map((e) {
                  return Column(
                    children: [
                      _FaqTile(question: e.value.q, answer: e.value.a),
                      if (e.key < _faqs.length - 1)
                        const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.divider),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            _sectionLabel('QUICK LINKS', const Color(0xFF0891B2)),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _LinkTile(
                    icon: Icons.description_outlined,
                    label: 'Driver Terms & Conditions',
                    iconColor: AppColors.primary,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 18, color: AppColors.divider),
                  _LinkTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    iconColor: const Color(0xFF7C3AED),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 18, color: AppColors.divider),
                  _LinkTile(
                    icon: Icons.email_outlined,
                    label: 'Email Support',
                    iconColor: const Color(0xFF0891B2),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 3, height: 13,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 1.2,
          )),
      ],
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(label,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.question,
                    style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                ),
                Icon(
                  _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.textHint, size: 20,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(widget.answer,
                style: GoogleFonts.outfit(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  const _LinkTile({required this.icon, required this.label, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
