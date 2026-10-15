import 'package:flutter/material.dart';

import 'pop_in.dart';

/// One welcome page: a big emoji, a title and an explanation
class OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String text;

  const OnboardingPage({
    super.key,
    required this.emoji,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PopIn(child: Text(emoji, style: const TextStyle(fontSize: 88))),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
