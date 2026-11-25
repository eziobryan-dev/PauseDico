import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tier_colors.dart';
import '../models/alphabet_tier_model.dart';
import '../services/level_service.dart';
import 'bookmark_art.dart';
import 'info_sheet.dart';

/// Legend of the profile resources (level, streak, words, letters,
/// fragments, bookmarks), named after the current Alphadex [tier]
abstract class ResourcesInfoSheet {
  static Future<void> show(BuildContext context, {required AlphabetTier tier}) {
    final tierColor = TierColors.dark(tier);
    return InfoSheet.show(
      context,
      title: 'Tes ressources',
      rows: [
        InfoSheetRow(
          icon: Icons.trending_up,
          color: Theme.of(context).colorScheme.primary,
          title: 'Niveau et XP',
          description: "L'XP se gagne en révélant des mots, en enchaînant les jours, "
              "en complétant l'Alphadex et en réussissant les quiz. "
              'Niveau maximum : ${LevelService.maxLevel}.',
        ),
        const InfoSheetRow(
          icon: Icons.local_fire_department,
          color: AppColors.tertiary,
          title: 'Série',
          description: "Jours d'affilée où tu as révélé ton mot du jour (le dimanche, "
              'jour du quiz, ne la casse pas). Bonus à 3, 7 et 30 jours, puis tous '
              'les 100 jours. Le record est ta meilleure série.',
        ),
        const InfoSheetRow(
          icon: Icons.menu_book_rounded,
          color: AppColors.info,
          title: 'Mots débloqués',
          description: 'Tous les mots du jour révélés. Tous les 50 mots : un bonus '
              "d'XP et un fragment de marque-page.",
        ),
        InfoSheetRow(
          icon: Icons.abc,
          color: tierColor,
          title: 'Lettres ${tier.femininePlural}',
          description: "La première lettre de chaque mot découvert s'ajoute à ton "
              "Alphadex. Une fois les 26 lettres dorées réunies, l'Alphadex "
              "d'émeraude commence.",
        ),
        InfoSheetRow(
          art: BookmarkArt.fragment(tier: tier, size: 20),
          color: tierColor,
          title: 'Fragments',
          description: 'Parfois trouvés en révélant un mot. '
              '${AppConstants.fragmentsPerBookmark} fragments s\'assemblent '
              'automatiquement en un marque-page.',
        ),
        InfoSheetRow(
          art: BookmarkArt(tier: tier, size: 20),
          color: tierColor,
          title: 'Marque-pages',
          description: "Débloque la lettre de ton choix dans l'Alphadex, "
              'même sans mot qui commence par elle.',
        ),
      ],
    );
  }
}
