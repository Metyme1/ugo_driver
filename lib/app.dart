import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'services/api_service.dart';

final appLocale = ValueNotifier<Locale>(const Locale('en'));

class UGoDriverApp extends StatefulWidget {
  const UGoDriverApp({super.key});

  @override
  State<UGoDriverApp> createState() => _UGoDriverAppState();
}

class _UGoDriverAppState extends State<UGoDriverApp> {
  @override
  void initState() {
    super.initState();
    ApiService().sessionExpired.addListener(_onSessionExpired);
    appLocale.addListener(_onLocaleChange);
  }

  void _onSessionExpired() {
    final router = AppRouter.router;
    router.go('/login');
  }

  void _onLocaleChange() => setState(() {});

  @override
  void dispose() {
    ApiService().sessionExpired.removeListener(_onSessionExpired);
    appLocale.removeListener(_onLocaleChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UGO Driver',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      locale: appLocale.value,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
      ],
    );
  }
}
