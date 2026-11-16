import 'package:flutter/material.dart';

/// "Regarder une pub : +1 skip", shown in the reveal overlay when the user has
/// no skip left. Shows a spinner while the ad loads and plays.
class RewardedSkipButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onPressed;

  const RewardedSkipButton({
    super.key,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: isBusy ? null : onPressed,
      icon: isBusy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.ondemand_video_rounded, size: 20),
      label: const Text('Regarder une pub : +1 skip'),
    );
  }
}
