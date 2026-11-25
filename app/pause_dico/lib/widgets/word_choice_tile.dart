import 'package:flutter/material.dart';

/// One of the 3 daily word candidates: the word in big letters, its theme
/// below in small italics. Highlighted (border and check) when selected.
class WordChoiceTile extends StatelessWidget {
  final String name;
  final String theme;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const WordChoiceTile({
    super.key,
    required this.name,
    required this.theme,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: isSelected ? Colors.white : Colors.transparent,
        width: 3,
      ),
    );

    return AnimatedScale(
      scale: isSelected ? 1.04 : 1,
      duration: const Duration(milliseconds: 150),
      child: Material(
        color: color,
        elevation: isSelected ? 12 : 6,
        shadowColor: color.withValues(alpha: 0.6),
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        theme,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: isSelected ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(Icons.check_circle, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
