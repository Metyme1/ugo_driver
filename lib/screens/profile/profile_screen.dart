import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final initials =
        '${user?.firstName.isNotEmpty == true ? user!.firstName[0] : ''}${user?.lastName.isNotEmpty == true ? user!.lastName[0] : ''}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: context.rv(80.0, 96.0, 108.0),
                        height: context.rv(80.0, 96.0, 108.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            initials.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: context.rv(28.0, 34.0, 40.0),
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.fullName ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: context.rv(20.0, 22.0, 24.0),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone ?? '',
                        style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6,
                              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Driver', style: GoogleFonts.outfit(color: AppColors.accentLight, fontWeight: FontWeight.w400, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(context.hPad),
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  _Section(
                    title: 'ACCOUNT',
                    icon: Icons.person_outline_rounded,
                    items: [
                      _Tile(icon: Icons.person_outline_rounded, label: 'Full Name', value: user?.fullName ?? '-'),
                      _Tile(icon: Icons.phone_outlined, label: 'Phone', value: user?.phone ?? '-'),
                      _Tile(icon: Icons.email_outlined, label: 'Email', value: user?.email ?? '-'),
                      _Tile(icon: Icons.location_on_outlined, label: 'Address', value: user?.address ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _Section(
                    title: 'EARNINGS',
                    icon: Icons.account_balance_wallet_outlined,
                    items: [
                      _ActionTile(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'My Earnings',
                        color: AppColors.accent,
                        onTap: () => context.push('/billing'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _Section(
                    title: 'SETTINGS',
                    icon: Icons.settings_outlined,
                    items: [
                      _ActionTile(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () => context.push('/profile/edit')),
                      _ActionTile(icon: Icons.lock_outline_rounded, label: 'Change Password', onTap: () => context.push('/profile/change-password')),
                      _ActionTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.push('/notifications')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _Section(
                    title: 'SUPPORT',
                    icon: Icons.help_outline_rounded,
                    items: [
                      _ActionTile(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
                      _ActionTile(icon: Icons.info_outline_rounded, label: 'About UGO Driver', onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Logout
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                          content: Text('Are you sure you want to logout?', style: GoogleFonts.outfit()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.textSecondary))),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text('Logout', style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w500))),
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
                          Text('Logout',
                            style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w500, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> items;
  const _Section({required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 13, color: AppColors.textHint),
              const SizedBox(width: 5),
              Text(title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHint,
                  fontSize: 11,
                  letterSpacing: 1,
                )),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < items.length - 1)
                    const Divider(height: 1, indent: 52, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

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
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(value,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 13, color: AppColors.textPrimary),
              textAlign: TextAlign.end),
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
  final Color? color;
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: c),
            ),
            const SizedBox(width: 14),
            Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

