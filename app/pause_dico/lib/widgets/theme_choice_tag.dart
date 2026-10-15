import 'package:flutter/material.dart';

/// Big rounded tag showing a hidden word's theme only (nothing hints at the
/// word, not even the weekly mystery letter). A spinner shows while the
/// chosen word is being revealed.
class ThemeChoiceTag extends StatelessWidget {
  final String theme;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const ThemeChoiceTag({
    super.key,
    required this.theme,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      elevation: 8,
      shadowColor: color.withValues(alpha: 0.6),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 240),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    theme,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
