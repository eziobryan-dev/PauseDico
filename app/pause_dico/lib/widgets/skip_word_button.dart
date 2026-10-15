import 'package:flutter/material.dart';

/// "Je veux un autre mot" button showing the remaining skip tokens.
/// Disabled when there are no tokens left or [onPressed] is null.
class SkipWordButton extends StatelessWidget {
  final int skipsLeft;
  final VoidCallback? onPressed;

  const SkipWordButton({
    super.key,
    required this.skipsLeft,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      onPressed: skipsLeft > 0 ? onPressed : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(child: Text('Je veux un autre mot')),
          const SizedBox(width: 8),
          const Icon(Icons.replay, size: 18),
          const SizedBox(width: 2),
          Text('$skipsLeft', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
