import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../config/theme.dart';
import '../../services/group_service.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _groupService = GroupService();
  StreamSubscription<List<ConnectivityResult>>? _connectSub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initConnectivity());
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted) setState(() => _isOffline = offline);
      if (!offline) _syncQueue();

      _connectSub = Connectivity().onConnectivityChanged.listen((results) {
        final wasOffline = _isOffline;
        final offline = results.every((r) => r == ConnectivityResult.none);
        if (mounted) setState(() => _isOffline = offline);
        if (wasOffline && !offline) _syncQueue();
      });
    } catch (_) {}
  }

  Future<void> _syncQueue() async {
    final count = await _groupService.syncOfflineScans();
    if (count > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Synced $count offline ride${count == 1 ? '' : 's'} â€” earnings updated'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ));
    }
  }

  @override
  void dispose() {
    _connectSub?.cancel();
    super.dispose();
  }

  static int _indexForLocation(String location) {
    if (location.startsWith('/routes')) return 1;
    if (location.startsWith('/groups')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexForLocation(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.child,
      bottomNavigationBar: _BottomBar(
        selectedIndex: selectedIndex,
        onHome: () => context.go('/home'),
        onRoutes: () => context.go('/routes'),
        onScan: () => context.push('/scan'),
        onGroups: () => context.go('/groups'),
        onProfile: () => context.go('/profile'),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onHome;
  final VoidCallback onRoutes;
  final VoidCallback onScan;
  final VoidCallback onGroups;
  final VoidCallback onProfile;

  const _BottomBar({
    required this.selectedIndex,
    required this.onHome,
    required this.onRoutes,
    required this.onScan,
    required this.onGroups,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded,
                  label: 'Home', isSelected: selectedIndex == 0, onTap: onHome),
              _NavItem(icon: Icons.route_outlined, selectedIcon: Icons.route_rounded,
                  label: 'Routes', isSelected: selectedIndex == 1, onTap: onRoutes),
              _ScanButton(onTap: onScan),
              _NavItem(icon: Icons.groups_2_outlined, selectedIcon: Icons.groups_2_rounded,
                  label: 'Groups', isSelected: selectedIndex == 3, onTap: onGroups),
              _NavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded,
                  label: 'Profile', isSelected: selectedIndex == 4, onTap: onProfile),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.primary : AppColors.textHint,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

