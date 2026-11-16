import 'package:flutter/material.dart';

import '../core/theme/tier_colors.dart';
import '../models/alphabet_tier_model.dart';
import 'reveal_step_view.dart';

/// Congratulations when the gold Alphadex is completed (the emerald one
/// starts), or when the emerald one is completed too
class EmeraldAlphadexView extends StatelessWidget {
  static const unlockedText =
      'Félicitations pour avoir réussi à compléter votre alphadex. Mais vous '
      "n'êtes en fait qu'à mi-parcours. Vous avez débloqué l'alphadex "
      "d'émeraude. Complétez à nouveau toutes les lettres de l'alphadex, "
      'couleur émeraude.';
  static const completedText =
      "Vous avez complété l'alphadex d'émeraude : toutes les lettres brillent. "
      'Chapeau, maître des mots !';

  final bool completed;
  final VoidCallback onContinue;

  const EmeraldAlphadexView({super.key, required this.completed, required this.onContinue});

  /// Same content as a dark full-screen dialog (outside the reveal overlay)
  static Future<void> show(BuildContext context, {required bool completed}) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      pageBuilder: (context, _, _) => Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: EmeraldAlphadexView(
                completed: completed,
                onContinue: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emerald = TierColors.main(AlphabetTier.emerald);
    return RevealStepView(
      title: completed ? "Alphadex d'émeraude complet !" : 'Félicitations !',
      art: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: TierColors.shine(AlphabetTier.emerald)),
          boxShadow: [BoxShadow(color: emerald.withValues(alpha: 0.6), blurRadius: 30)],
        ),
        child: const Icon(Icons.diamond_rounded, size: 72, color: Colors.white),
      ),
      caption: completed ? completedText : unlockedText,
      onContinue: onContinue,
    );
  }
}
