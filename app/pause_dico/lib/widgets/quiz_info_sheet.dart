import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/special_quiz_model.dart';
import 'info_sheet.dart';
import 'next_quiz_chip.dart';

/// How the weekly, monthly and yearly quizzes work, with the delay until the
/// next weekly one
abstract class QuizInfoSheet {
  static Future<void> show(BuildContext context, {required int daysUntilWeekly}) {
    final delay = NextQuizChip.delayLabel(daysUntilWeekly);
    return InfoSheet.show(
      context,
      title: 'Les quiz',
      rows: [
        InfoSheetRow(
          icon: Icons.star,
          color: AppColors.tertiary,
          title: '${QuizKind.weekly.title} : $delay',
          description: 'Chaque dimanche, ${AppConstants.weeklyQuizQuestions} questions '
              'sur les mots découverts du lundi au samedi (au moins '
              '${AppConstants.weeklyQuizMinWords} mots dans la semaine).',
        ),
        InfoSheetRow(
          icon: Icons.calendar_month,
          color: AppColors.info,
          title: QuizKind.monthly.title,
          description: 'Tous les ${AppConstants.monthlyQuizPeriod} jours depuis ton '
              'inscription, si tu as découvert au moins '
              '${AppConstants.monthlyQuizMinWords} mots sur la période : '
              '${AppConstants.monthlyQuizQuestions} questions.',
        ),
        InfoSheetRow(
          icon: Icons.emoji_events,
          color: AppColors.secondary,
          title: QuizKind.yearly.title,
          description: 'Tous les ${AppConstants.yearlyQuizPeriod} jours, avec au moins '
              '${AppConstants.yearlyQuizMinWords} mots découverts sur l\'année : '
              '${AppConstants.yearlyQuizQuestions} questions.',
        ),
        const InfoSheetRow(
          icon: Icons.bolt,
          color: AppColors.success,
          title: 'Récompenses',
          description: 'Chaque bonne réponse rapporte de l\'XP, avec un bonus pour un '
              'quiz parfait. Seul le premier passage compte.',
        ),
      ],
    );
  }
}
