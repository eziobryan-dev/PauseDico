import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pause_dico/core/utils/date_helpers.dart';
import 'package:pause_dico/models/user_game_profile_model.dart';
import 'package:pause_dico/services/level_service.dart';

UserGameProfileModel _profile({required int streak, required DateTime? lastReveal}) {
  return UserGameProfileModel(
    userId: 'u',
    level: 1,
    xp: 0,
    nbWords: 0,
    nbQuizWeeklyCompleted: 0,
    nbQuizMonthlyCompleted: 0,
    nbQuizYearlyCompleted: 0,
    nbSkip: 1,
    currentStreak: streak,
    bestStreak: streak,
    lastRevealDate: lastReveal,
    lettersMask: 0,
    goldBookmarkMask: 0,
    emeraldSince: null,
    emeraldMask: 0,
    emeraldBookmarkMask: 0,
    bookmarkFragments: 0,
    bookmarks: 0,
  );
}

void main() {
  group('LevelService', () {
    test('courbe : niveau 2 à 60 XP, plafond 50 à 14 700 XP', () {
      expect(LevelService.xpForLevel(1), 0);
      expect(LevelService.xpForLevel(2), 60);
      expect(LevelService.xpForLevel(50), 14700);
    });

    test('levelForXp suit les seuils et plafonne', () {
      expect(LevelService.levelForXp(0), 1);
      expect(LevelService.levelForXp(59), 1);
      expect(LevelService.levelForXp(60), 2);
      expect(LevelService.levelForXp(300), 5);
      expect(LevelService.levelForXp(999999), 50);
    });

    test('progression et XP restante', () {
      expect(LevelService.progress(30, 1), 0.5);
      expect(LevelService.xpToNextLevel(30, 1), 30);
      expect(LevelService.progress(14700, 50), 1);
      expect(LevelService.xpToNextLevel(14700, 50), 0);
    });
  });

  group('Série active', () {
    // Mercredi 18 novembre 2026
    final wednesday = DateTime(2026, 11, 18);

    test('compte si le dernier mot date d\'hier ou d\'aujourd\'hui', () {
      expect(_profile(streak: 5, lastReveal: wednesday).activeStreak(wednesday), 5);
      expect(
        _profile(streak: 5, lastReveal: DateHelpers.addDays(wednesday, -1)).activeStreak(wednesday),
        5,
      );
    });

    test('cassée après un jour sans mot', () {
      expect(
        _profile(streak: 5, lastReveal: DateHelpers.addDays(wednesday, -2)).activeStreak(wednesday),
        0,
      );
    });

    test('le dimanche (quiz) ne casse pas la série', () {
      final monday = DateTime(2026, 11, 23);
      final saturday = DateTime(2026, 11, 21);
      expect(_profile(streak: 6, lastReveal: saturday).activeStreak(monday), 6);
    });
  });

  group('DateHelpers', () {
    test('semaine du quiz : lundi au samedi avant le dimanche', () {
      final sunday = DateTime(2026, 11, 22);
      expect(DateHelpers.weekStart(sunday), DateTime(2026, 11, 16));
      expect(DateHelpers.weekEnd(sunday), DateTime(2026, 11, 21));
    });

    test('addDays reste à minuit au changement d\'heure', () {
      final beforeDst = DateTime(2026, 10, 24);
      expect(DateHelpers.addDays(beforeDst, 1), DateTime(2026, 10, 25));
      expect(DateHelpers.daysBetween(beforeDst, DateTime(2026, 10, 26)), 2);
    });

    test('rechargement après minuit ou après l\'heure du rappel', () {
      const reminder = TimeOfDay(hour: 9, minute: 0);
      final evening = DateTime(2026, 11, 17, 22);
      expect(DateHelpers.hasCrossedDailyBoundary(evening, DateTime(2026, 11, 18, 1), reminder), isTrue);

      final morning = DateTime(2026, 11, 18, 8);
      expect(DateHelpers.hasCrossedDailyBoundary(morning, DateTime(2026, 11, 18, 8, 30), reminder), isFalse);
      expect(DateHelpers.hasCrossedDailyBoundary(morning, DateTime(2026, 11, 18, 9, 5), reminder), isTrue);
    });
  });
}
