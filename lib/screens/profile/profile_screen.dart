import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final initials =
        '${user?.firstName.isNotEmpty == true ? user!.firstName[0] : ''}'
        '${user?.lastName.isNotEmpty == true ? user!.lastName[0] : ''}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(user: user, initials: initials, l: l),
            Padding(
              padding: EdgeInsets.fromLTRB(context.hPad, 8, context.hPad, 0),
              child: Column(
                children: [
                  _Section(
                    title: l.accountSectionLabel,
                    accentColor: AppColors.primary,
                    items: [
                      _Tile(icon: Icons.person_outline_rounded,   label: l.fullName, value: user?.fullName ?? '-'),
                      _Tile(icon: Icons.phone_outlined,            label: l.phone,    value: user?.phone    ?? '-'),
                      _Tile(icon: Icons.email_outlined,            label: l.email,    value: user?.email    ?? '-'),
                      _Tile(icon: Icons.location_on_outlined,      label: l.address,  value: user?.address  ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _Section(
                    title: l.earningsSectionLabel,
                    accentColor: AppColors.accent,
                    items: [
                      _ActionTile(
                        icon: Icons.account_balance_wallet_outlined,
                        label: l.myEarnings,
                        iconColor: AppColors.accent,
                        onTap: () => context.push('/billing'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _Section(
                    title: l.settingsSectionLabel,
                    accentColor: const Color(0xFF7C3AED),
                    items: [
                      _ActionTile(
                        icon: Icons.edit_outlined,
                        label: l.editProfile,
                        iconColor: AppColors.primary,
                        onTap: () => context.push('/profile/edit'),
                      ),
                      _ActionTile(
                        icon: Icons.lock_outline_rounded,
                        label: l.changePassword,
                        iconColor: const Color(0xFF7C3AED),
                        onTap: () => context.push('/profile/change-password'),
                      ),
                      _ActionTile(
                        icon: Icons.notifications_outlined,
                        label: l.notifications,
                        iconColor: const Color(0xFFD97706),
                        onTap: () => context.push('/notifications'),
                      ),
                      _LanguageTile(l: l),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _Section(
                    title: l.supportSectionLabel,
                    accentColor: const Color(0xFF0891B2),
                    items: [
                      _ActionTile(
                        icon: Icons.help_outline_rounded,
                        label: l.helpAndSupport,
                        iconColor: const Color(0xFF0891B2),
                        onTap: () => context.push('/profile/help'),
                      ),
                      _ActionTile(
                        icon: Icons.info_outline_rounded,
                        label: l.aboutUGODriver,
                        iconColor: const Color(0xFF059669),
                        onTap: () => context.push('/profile/about'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _LogoutButton(l: l),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final String initials;
  final AppLocalizations l;
  const _ProfileHeader({required this.user, required this.initials, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF0D47A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Center(
                      child: Text(initials.toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 2)),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(user?.fullName ?? '',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.3)),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone_outlined, size: 13, color: Colors.white60),
                  const SizedBox(width: 4),
                  Text(user?.phone ?? '', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Chip(icon: Icons.directions_car_rounded, label: l.driver, iconColor: AppColors.accentLight),
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.check_circle_outline_rounded,
                    label: (user?.status ?? 'active') == 'active' ? l.active : l.inactive,
                    iconColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  const _Chip({required this.icon, required this.label, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Section ─────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<Widget> items;
  const _Section({required this.title, required this.accentColor, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(width: 3, height: 13, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < items.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 18, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Tiles ───────────────────────────────────────────────────────────────────

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Tile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final c = iconColor ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: c),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language tile ───────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  final AppLocalizations l;
  const _LanguageTile({required this.l});

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(l.selectLanguage, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _LangOption(
                flag: '🇺🇸',
                label: l.english,
                locale: const Locale('en'),
              ),
              const SizedBox(height: 8),
              _LangOption(
                flag: '🇪🇹',
                label: l.amharic,
                locale: const Locale('am'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = appLocale.value.languageCode == 'am' ? l.amharic : l.english;
    return InkWell(
      onTap: () => _showLanguageSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(l.language, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
            Text(currentLang, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final Locale locale;
  const _LangOption({required this.flag, required this.label, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isSelected = appLocale.value == locale;
    return GestureDetector(
      onTap: () {
        appLocale.value = locale;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
            if (isSelected) const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Logout ──────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final AppLocalizations l;
  const _LogoutButton({required this.l});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(l.logoutConfirmTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
            content: Text(l.logoutConfirmMsg, style: GoogleFonts.outfit()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.cancel, style: GoogleFonts.outfit(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.logout, style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await context.read<AuthProvider>().logout();
          if (context.mounted) context.go('/login');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Text(l.logout, style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w500, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
