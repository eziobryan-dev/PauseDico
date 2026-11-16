import 'package:flutter/material.dart';

import '../core/theme/tier_colors.dart';
import '../models/alphabet_tier_model.dart';

/// A golden / emerald bookmark (ribbon with a notched tail), or one of its
/// fragments: a jagged shard ([fragmentIndex] picks one of a few shapes).
/// [size] is the height of the drawing.
class BookmarkArt extends StatelessWidget {
  final AlphabetTier tier;
  final double size;
  final int? fragmentIndex;

  const BookmarkArt({super.key, required this.tier, required this.size})
      : fragmentIndex = null;

  const BookmarkArt.fragment({
    super.key,
    required this.tier,
    required this.size,
    this.fragmentIndex = 0,
  });

  bool get isFragment => fragmentIndex != null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFragment ? size : size * 0.42,
      height: size,
      child: CustomPaint(
        painter: _BookmarkPainter(
          colors: TierColors.shine(tier),
          fragmentIndex: fragmentIndex,
        ),
      ),
    );
  }
}

class _BookmarkPainter extends CustomPainter {
  final List<Color> colors;
  final int? fragmentIndex;

  _BookmarkPainter({required this.colors, required this.fragmentIndex});

  /// Shard outlines, in a unit square
  static const _shards = [
    [Offset(0.2, 0.05), Offset(0.85, 0.15), Offset(0.95, 0.6), Offset(0.55, 0.95), Offset(0.1, 0.7)],
    [Offset(0.35, 0.0), Offset(0.95, 0.3), Offset(0.8, 0.9), Offset(0.15, 0.95), Offset(0.05, 0.35)],
    [Offset(0.1, 0.15), Offset(0.6, 0.0), Offset(0.95, 0.45), Offset(0.7, 1.0), Offset(0.2, 0.8)],
  ];

  Path _path(Size size) {
    final w = size.width;
    final h = size.height;
    final index = fragmentIndex;
    if (index != null) {
      final points = _shards[index % _shards.length];
      return Path()..addPolygon([for (final p in points) Offset(p.dx * w, p.dy * h)], true);
    }
    // Ribbon with rounded top corners and a V notch at the bottom
    return Path()
      ..moveTo(0, h * 0.04)
      ..quadraticBezierTo(0, 0, w * 0.1, 0)
      ..lineTo(w * 0.9, 0)
      ..quadraticBezierTo(w, 0, w, h * 0.04)
      ..lineTo(w, h)
      ..lineTo(w / 2, h * 0.8)
      ..lineTo(0, h)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    final rect = Offset.zero & size;

    canvas.drawShadow(path, Colors.black, 4, false);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(rect),
    );
    // Engraved edge
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.04
        ..color = colors.first.withValues(alpha: 0.8),
    );

    if (fragmentIndex == null) {
      // Diamond ornament near the top
      final c = Offset(size.width / 2, size.height * 0.18);
      final r = size.width * 0.18;
      canvas.drawPath(
        Path()
          ..addPolygon([
            Offset(c.dx, c.dy - r),
            Offset(c.dx + r, c.dy),
            Offset(c.dx, c.dy + r),
            Offset(c.dx - r, c.dy),
          ], true),
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_BookmarkPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.fragmentIndex != fragmentIndex;
}
