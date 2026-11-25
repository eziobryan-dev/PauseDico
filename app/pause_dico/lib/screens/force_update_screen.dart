import 'package:flutter/material.dart';

import '../services/app_update_service.dart';
import '../widgets/app_logo.dart';

/// Blocking screen shown when the installed version is too old to work
/// with the server: the only way out is the store page
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 96),
                  const SizedBox(height: 24),
                  Text(
                    'Mise à jour requise',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Une nouvelle version de PauseDico est disponible. '
                    'Mets à jour l\'application pour continuer à découvrir tes mots.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: AppUpdateService.openStore,
                    icon: const Icon(Icons.system_update),
                    label: const Text('Mettre à jour'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
