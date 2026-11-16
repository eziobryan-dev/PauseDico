import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/tier_colors.dart';
import '../models/alphabet_tier_model.dart';
import 'bookmark_art.dart';

/// The 7 fragments spin in a circle while closing in on the center, then
/// merge into a bookmark. [onDone] fires once the bookmark is shown.
class BookmarkAssemblyAnimation extends StatefulWidget {
  final AlphabetTier tier;
  final double size;
  final VoidCallback? onDone;

  const BookmarkAssemblyAnimation({
    super.key,
    required this.tier,
    this.size = 220,
    this.onDone,
  });

  @override
  State<BookmarkAssemblyAnimation> createState() =>
      _BookmarkAssemblyAnimationState();
}

class _BookmarkAssemblyAnimationState extends State<BookmarkAssemblyAnimation>
    with SingleTickerProviderStateMixin {
  /// Share of the animation where the fragments turn into the bookmark
  static const _mergeStart = 0.78;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      HapticFeedback.heavyImpact();
      widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final fragmentSize = size * 0.22;

    return SizedBox.square(
      dimension: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          // Closing in faster and faster
          final closing = Curves.easeInCubic.transform((t / _mergeStart).clamp(0, 1));
          final radius = (size - fragmentSize) / 2 * (1 - closing);
          final angle = t * math.pi * 4;
          final merge = ((t - _mergeStart) / (1 - _mergeStart)).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Glow growing as the fragments meet
              Container(
                width: size * (0.3 + 0.5 * closing),
                height: size * (0.3 + 0.5 * closing),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TierColors.main(widget.tier).withValues(alpha: 0.5 * closing),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < AppConstants.fragmentsPerBookmark; i++)
                Transform.translate(
                  offset: Offset.fromDirection(
                    angle + 2 * math.pi * i / AppConstants.fragmentsPerBookmark,
                    radius,
                  ),
                  child: Opacity(
                    opacity: 1 - merge,
                    child: Transform.rotate(
                      angle: angle * 1.5 + i,
                      child: BookmarkArt.fragment(
                        tier: widget.tier,
                        size: fragmentSize,
                        fragmentIndex: i,
                      ),
                    ),
                  ),
                ),
              if (merge > 0)
                Opacity(
                  opacity: merge,
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * Curves.elasticOut.transform(merge),
                    child: BookmarkArt(tier: widget.tier, size: size * 0.75),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
