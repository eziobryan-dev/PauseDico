import 'package:flutter/material.dart';

/// Stand-in for the AdMob banner in simulated mode: same place, no SDK call
class SimulatedAdBanner extends StatelessWidget {
  const SimulatedAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        color: colorScheme.surfaceContainerHighest,
        child: Text(
          'Bannière publicitaire (simulée)',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
