import 'package:flutter/material.dart';

import '../core/theme/theme_switcher.dart';
import '../services/theme_service.dart';

/// Card with a switch toggling between light and dark mode
class ThemeToggleCard extends StatelessWidget {
  const ThemeToggleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeSwitcher.themeMode,
        builder: (context, mode, _) {
          final isDark = mode == ThemeMode.dark ||
              (mode == ThemeMode.system &&
                  MediaQuery.of(context).platformBrightness == Brightness.dark);

          return SwitchListTile(
            title: const Text('Mode Sombre'),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            value: isDark,
            onChanged: ThemeService.setDarkTheme,
          );
        },
      ),
    );
  }
}
