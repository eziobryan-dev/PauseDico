import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Heart toggle: empty when not liked, filled when liked.
/// The heart flips right away, then taps are ignored until [onChanged]
/// (the database update) completes; it reverts if the update fails.
class LikeButton extends StatefulWidget {
  final bool liked;

  /// Saves the new state and returns the state actually saved
  final Future<bool> Function(bool liked) onChanged;

  const LikeButton({super.key, required this.liked, required this.onChanged});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _liked = widget.liked;
  bool _isSaving = false;

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSaving && widget.liked != oldWidget.liked) _liked = widget.liked;
  }

  Future<void> _toggle() async {
    if (_isSaving) return;
    HapticFeedback.lightImpact();
    final previous = _liked;
    setState(() {
      _isSaving = true;
      _liked = !previous;
    });

    try {
      final saved = await widget.onChanged(!previous);
      if (mounted) setState(() => _liked = saved);
    } catch (e) {
      if (mounted) setState(() => _liked = previous);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;

    return IconButton(
      tooltip: _liked ? 'Je n\'aime plus' : 'J\'aime',
      onPressed: _toggle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          _liked ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(_liked),
          color: color,
          size: 30,
        ),
      ),
    );
  }
}
