import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../services/link_service.dart';

/// Discreet attribution of the definitions (Wiktionary, CC BY-SA 4.0).
/// Tapping it opens the license.
class DefinitionsCredit extends StatelessWidget {
  const DefinitionsCredit({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => LinkService.open(Uri.parse(AppConstants.definitionsLicenseUrl)),
      child: Text(
        'Définitions : Wiktionnaire, CC BY-SA 4.0',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
