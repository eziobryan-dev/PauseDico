import 'package:flutter/material.dart';

import 'fade_in.dart';
import 'green_action_button.dart';
import 'pop_in.dart';

/// One step of the dark reveal overlay: a white title, an illustration, an
/// optional caption and a "Continuer" button (hidden while [onContinue] is null)
class RevealStepView extends StatelessWidget {
  final String title;
  final Widget art;
  final String? caption;
  final String actionLabel;
  final VoidCallback? onContinue;

  /// Title below the art (e.g. once an animation produced the art)
  final bool titleBelowArt;

  const RevealStepView({
    super.key,
    required this.title,
    required this.art,
    this.caption,
    this.actionLabel = 'Continuer',
    required this.onContinue,
    this.titleBelowArt = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = FadeIn(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!titleBelowArt) ...[titleText, const SizedBox(height: 24)],
        Center(child: PopIn(child: art)),
        if (titleBelowArt && onContinue != null) ...[const SizedBox(height: 24), titleText],
        if (caption != null && onContinue != null) ...[
          const SizedBox(height: 12),
          FadeIn(
            child: Text(
              caption!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ),
        ],
        const SizedBox(height: 32),
        // Same height before and after: no jump when the button appears
        Opacity(
          opacity: onContinue == null ? 0 : 1,
          child: GreenActionButton(label: actionLabel, onPressed: onContinue),
        ),
      ],
    );
  }
}
