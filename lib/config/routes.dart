import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/nomination_model.dart';
import '../models/group_model.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/pending_approval_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/nominations/nominations_screen.dart';
import '../screens/nominations/nomination_detail_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_detail_screen.dart';
import '../screens/scan/scan_qr_screen.dart';
import '../screens/scan/scan_result_screen.dart';
import '../screens/scan/university_scan_result_screen.dart';
import '../models/university_scan_model.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/routes/route_management_screen.dart';
import '../widgets/common/main_shell.dart';
import '../screens/billing/driver_billing_screen.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

      // Auth (no shell)
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpScreen(
            phone: extra?['phone'] ?? '',
            purpose: extra?['purpose'] ?? 'registration',
          );
        },
      ),
      GoRoute(path: '/pending-approval', builder: (_, __) => const PendingApprovalScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResetPasswordScreen(phone: extra?['phone'] ?? '', otp: extra?['otp'] ?? '');
        },
      ),

      // Main tabs — all share the persistent bottom nav via MainShell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/routes', builder: (_, __) => const RouteManagementScreen()),
          GoRoute(path: '/nominations', builder: (_, __) => const NominationsScreen()),
          GoRoute(path: '/groups', builder: (_, __) => const GroupsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Detail / modal screens — pushed on root navigator, no nav bar
      GoRoute(
        path: '/nominations/:groupId',
        builder: (_, state) {
          final nomination = state.extra as DriverNomination;
          return NominationDetailScreen(nomination: nomination);
        },
      ),
      GoRoute(
        path: '/groups/:id',
        builder: (_, state) => GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/scan', builder: (_, __) => const ScanQrScreen()),
      GoRoute(
        path: '/scan/result',
        builder: (_, state) => ScanResultScreen(result: state.extra as ScanResult),
      ),
      GoRoute(
        path: '/scan/university-result',
        builder: (_, state) => UniversityScanResultScreen(
          preview: state.extra as UniversityBookingPreview,
        ),
      ),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/profile/change-password', builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: '/billing', builder: (_, __) => const DriverBillingScreen()),
    ],
  );
}
