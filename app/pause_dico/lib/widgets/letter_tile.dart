import 'package:flutter/material.dart';

/// A letter of the alphabet collection: grey while locked, gold with a moving
/// shine once at least one word starting with it was discovered
class LetterTile extends StatefulWidget {
  final String letter;
  final bool unlocked;
  final VoidCallback? onTap;

  const LetterTile({
    super.key,
    required this.letter,
    required this.unlocked,
    this.onTap,
  });

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  static const _gold = [
    Color(0xFFB8860B),
    Color(0xFFFFD700),
    Color(0xFFFFF8DC),
    Color(0xFFFFD700),
    Color(0xFFB8860B),
  ];

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

    return InkWell(
      onTap: widget.unlocked ? widget.onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: widget.unlocked
            ? AnimatedBuilder(
                animation: _shine,
                child: text,
                builder: (context, child) => ShaderMask(
                  blendMode: BlendMode.srcIn,
                  // A light band sweeping across the gold
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment(-1 + 3 * _shine.value - 1, -0.5),
                    end: Alignment(1 + 3 * _shine.value - 1, 0.5),
                    colors: _gold,
                  ).createShader(bounds),
                  child: child,
                ),
              )
            : text,
      ),
    );
  }
}
