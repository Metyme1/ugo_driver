import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('About UGO Driver',
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
          children: [
            // App identity card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/icon/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('UGO Driver',
                    style: GoogleFonts.outfit(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Version 1.1.0',
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Text('Student Transport Platform',
                      style: GoogleFonts.outfit(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About text
            const _InfoCard(
              title: 'About UGO',
              icon: Icons.info_outline_rounded,
              iconColor: AppColors.primary,
              content:
                'UGO is a student transport management platform connecting parents, drivers, and school administrators. '
                'It enables safe, trackable, and organised school transport for families across Ethiopia.',
            ),
            const SizedBox(height: 14),

            const _InfoCard(
              title: 'Driver Mission',
              icon: Icons.directions_car_rounded,
              iconColor: AppColors.accent,
              content:
                'As a UGO driver you are responsible for the safe and timely transport of students. '
                'Your commitment to punctuality and professionalism directly impacts the trust families place in UGO.',
            ),
            const SizedBox(height: 24),

            // Details list
            _sectionLabel('APP INFO', AppColors.primary),
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
              child: const Column(
                children: [
                  _DetailRow(label: 'Version',      value: '1.1.0'),
                  Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.divider),
                  _DetailRow(label: 'Platform',     value: 'Android / iOS'),
                  Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.divider),
                  _DetailRow(label: 'Developer',    value: 'UGO Technologies'),
                  Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.divider),
                  _DetailRow(label: 'Contact',      value: 'support@ugo.et'),
                  Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.divider),
                  _DetailRow(label: 'Country',      value: 'Ethiopia'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('© 2025 UGO Technologies. All rights reserved.',
              style: GoogleFonts.outfit(
                color: AppColors.textHint, fontSize: 12),
              textAlign: TextAlign.center),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String content;
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(content,
                  style: GoogleFonts.outfit(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Text(label,
            style: GoogleFonts.outfit(
              fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
            style: GoogleFonts.outfit(
              fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
