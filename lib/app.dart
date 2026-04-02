import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'services/api_service.dart';

class UGoDriverApp extends StatefulWidget {
  const UGoDriverApp({super.key});

  @override
  State<UGoDriverApp> createState() => _UGoDriverAppState();
}

class _UGoDriverAppState extends State<UGoDriverApp> {
  @override
  void initState() {
    super.initState();
    // Listen for session expiry and redirect to login
    ApiService().sessionExpired.addListener(_onSessionExpired);
  }

  void _onSessionExpired() {
    final router = AppRouter.router;
    router.go('/login');
  }

  @override
  void dispose() {
    ApiService().sessionExpired.removeListener(_onSessionExpired);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UGO Driver',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
    );
  }
}
