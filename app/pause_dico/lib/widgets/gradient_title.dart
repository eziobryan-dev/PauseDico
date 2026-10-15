import 'package:flutter/material.dart';

/// Brand title ("PauseDico" by default) painted with the primary → secondary
/// gradient
class GradientTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const GradientTitle({super.key, this.text = 'PauseDico', this.style});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [colorScheme.primary, colorScheme.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: style?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white, // Required for ShaderMask
        ),
      ),
    );
  }
}
