import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_switcher.dart';
import 'debug/debug_menu_screen.dart';
import 'screens/auth_gate.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';

/// Debug scenario to open instead of the real app (debug builds only):
/// `flutter run --dart-define=SCENARIO=menu` (list) or `SCENARIO=<id>`
const String _scenario = String.fromEnvironment('SCENARIO');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode && _scenario.isNotEmpty) {
    // Simulated data only: Supabase is never initialized
    runApp(PauseDicoApp(
      home: DebugMenuScreen(autoStartId: _scenario == 'menu' ? null : _scenario),
    ));
    return;
  }

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseKey,
  );
  await NotificationService.init();
  await ThemeService.loadCached();

  runApp(const PauseDicoApp());
}

class PauseDicoApp extends StatelessWidget {
  final Widget home;

  const PauseDicoApp({super.key, this.home = const AuthGate()});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeSwitcher.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          themeMode: currentMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // French Material texts (date / time pickers, dialogs…)
          locale: const Locale('fr', 'FR'),
          supportedLocales: const [Locale('fr', 'FR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: home,
        );
      },
    );
  }
}
