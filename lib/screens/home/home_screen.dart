import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nomination_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/notifications_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    await Future.wait([
      context.read<NominationProvider>().loadNominations(),
      context.read<GroupProvider>().loadMyGroups(),
      context.read<NotificationsProvider>().loadNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final nominationProvider = context.watch<NominationProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final notifProvider = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${user?.firstName ?? 'Driver'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('UGO Driver Dashboard', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: Center(child: Text('${notifProvider.unreadCount}', style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold))),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row
              Row(
                children: [
                  _StatCard(
                    label: 'Active Groups',
                    value: groupProvider.groups.length.toString(),
                    icon: Icons.groups,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Pending Nominations',
                    value: nominationProvider.pendingCount.toString(),
                    icon: Icons.pending_actions,
                    color: nominationProvider.pendingCount > 0 ? AppColors.warning : AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pending nominations banner
              if (nominationProvider.pendingCount > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pending_actions, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${nominationProvider.pendingCount} new nomination${nominationProvider.pendingCount > 1 ? 's' : ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const Text('Groups are waiting for your response', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/nominations'),
                        child: const Text('View'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Quick Actions
              const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuickAction(icon: Icons.qr_code_scanner, label: 'Scan QR', color: AppColors.primary, onTap: () => context.push('/scan')),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.pending_actions, label: 'Nominations', color: AppColors.warning, onTap: () => context.push('/nominations')),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.groups, label: 'My Groups', color: const Color(0xFF1565C0), onTap: () => context.push('/groups')),
                ],
              ),
              const SizedBox(height: 24),

              // My Groups
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Groups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                  TextButton(onPressed: () => context.push('/groups'), child: const Text('See All')),
                ],
              ),
              const SizedBox(height: 8),
              if (groupProvider.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else if (groupProvider.groups.isEmpty)
                _EmptyCard(icon: Icons.groups_outlined, message: 'No active groups yet.\nAccept a nomination to get started.')
              else
                ...groupProvider.groups.take(3).map((g) => _GroupTile(
                  name: g.name,
                  school: g.schoolName,
                  members: g.currentMembers,
                  capacity: g.capacity,
                  status: g.status,
                  onTap: () => context.push('/groups/${g.id}'),
                )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          switch (i) {
            case 0: break;
            case 1: context.push('/nominations'); break;
            case 2: context.push('/scan'); break;
            case 3: context.push('/groups'); break;
            case 4: context.push('/profile'); break;
          }
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Badge(isLabelVisible: nominationProvider.pendingCount > 0, label: Text('${nominationProvider.pendingCount}'), child: const Icon(Icons.pending_actions_outlined)),
            selectedIcon: const Icon(Icons.pending_actions),
            label: 'Nominations',
          ),
          const NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan QR'),
          const NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Groups'),
          const NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
          child: Column(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final String name;
  final String school;
  final int members;
  final int capacity;
  final String status;
  final VoidCallback onTap;
  const _GroupTile({required this.name, required this.school, required this.members, required this.capacity, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
        child: Row(
          children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.groups, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(school, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$members/$capacity', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              const Text('students', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(icon, size: 48, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
      ]),
    );
  }
}
