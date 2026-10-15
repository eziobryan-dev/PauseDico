import 'package:flutter/material.dart';

import 'gradient_title.dart';

/// App bar title in the same style as the "PauseDico" brand title
class ScreenTitle extends StatelessWidget {
  final String text;

  const ScreenTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return GradientTitle(
      text: text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: -0.5),
    );
  }
}
