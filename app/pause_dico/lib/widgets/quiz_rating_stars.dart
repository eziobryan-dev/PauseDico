import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/quiz_result_model.dart';

/// The 3 stars of a quiz rating (filled up to [rating].stars)
class QuizRatingStars extends StatelessWidget {
  final QuizRating rating;
  final double size;

  const QuizRatingStars({super.key, required this.rating, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < rating.stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < rating.stars ? AppColors.warning : outline,
          ),
      ],
    );
  }
}
