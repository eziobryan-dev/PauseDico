/// Level curve and titles. Mirrors the server: going from level n to n+1
/// costs 20 + 10n xp, so reaching level L takes 5L² + 15L − 20 xp.
/// Capped at level 50, with no xp beyond.
abstract class LevelService {
  static const int maxLevel = 50;

  /// Titles unlocked at each level step
  static const Map<int, String> _titles = {
    1: 'Curieux',
    5: 'Apprenti',
    10: 'Liseur',
    15: 'Bibliophile',
    20: 'Lexicographe',
    25: 'Érudit',
    30: 'Encyclopédiste',
    35: 'Parnassien',
    40: 'Académicien',
    45: 'Immortel',
    50: 'Légende Littéraire',
  };

  /// Total xp needed to reach [level]
  static int xpForLevel(int level) => 5 * level * level + 15 * level - 20;

  /// Title of the highest step reached at [level]
  static String titleFor(int level) => _titles.entries
      .lastWhere((entry) => entry.key <= level)
      .value;

  /// Progress from [level] to the next one, between 0 and 1 (1 at max level)
  static double progress(int xp, int level) {
    if (level >= maxLevel) return 1;
    final start = xpForLevel(level);
    return (xp - start) / (xpForLevel(level + 1) - start);
  }

  /// Xp still needed to reach the next level (0 at max level)
  static int xpToNextLevel(int xp, int level) =>
      level >= maxLevel ? 0 : xpForLevel(level + 1) - xp;
}
