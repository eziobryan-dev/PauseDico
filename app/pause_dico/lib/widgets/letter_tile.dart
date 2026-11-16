import 'package:flutter/material.dart';

import '../core/theme/tier_colors.dart';
import '../models/alphabet_tier_model.dart';
import 'bookmark_art.dart';

/// A letter of the Alphadex: grey while locked, gold (or emerald) with a
/// moving shine once unlocked. A locked letter shows a small bookmark when
/// one can unlock it ([onUseBookmark]).
class LetterTile extends StatefulWidget {
  final String letter;
  final bool unlocked;
  final AlphabetTier tier;
  final VoidCallback? onTap;
  final VoidCallback? onUseBookmark;

  const LetterTile({
    super.key,
    required this.letter,
    required this.unlocked,
    required this.tier,
    this.onTap,
    this.onUseBookmark,
  });

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.unlocked) _shine.repeat();
  }

  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unlocked && !_shine.isAnimating) _shine.repeat();
    if (!widget.unlocked && _shine.isAnimating) _shine.stop();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'serif',
      fontFamilyFallback: const ['Georgia', 'Times New Roman'],
      fontWeight: FontWeight.w900,
      color: widget.unlocked
          ? Colors.white
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18),
    );

    final text = FittedBox(child: Text(widget.letter, style: style));
    final canUseBookmark = !widget.unlocked && widget.onUseBookmark != null;

    return InkWell(
      onTap: widget.unlocked ? widget.onTap : widget.onUseBookmark,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: widget.unlocked
                  ? AnimatedBuilder(
                      animation: _shine,
                      child: text,
                      builder: (context, child) => ShaderMask(
                        blendMode: BlendMode.srcIn,
                        // A light band sweeping across the letter
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment(-1 + 3 * _shine.value - 1, -0.5),
                          end: Alignment(1 + 3 * _shine.value - 1, 0.5),
                          colors: TierColors.shine(widget.tier),
                        ).createShader(bounds),
                        child: child,
                      ),
                    )
                  : text,
            ),
          ),
          if (canUseBookmark)
            Positioned(
              top: 2,
              right: 6,
              child: BookmarkArt(tier: widget.tier, size: 22),
            ),
        ],
      ),
    );
  }
}
