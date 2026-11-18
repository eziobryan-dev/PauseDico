import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pause_dico/debug/debug_scenarios.dart';
import 'package:pause_dico/debug/fake_words.dart';
import 'package:pause_dico/models/alphabet_tier_model.dart';
import 'package:pause_dico/widgets/bookmark_art.dart';
import 'package:pause_dico/widgets/letter_tile.dart';
import 'package:pause_dico/widgets/quiz_rating_stars.dart';
import 'package:pause_dico/widgets/theme_choice_tag.dart';

import 'helpers/scenario_harness.dart';

/// Opens the daily word: picks the first theme, then shows the word card
Future<void> revealFirstTheme(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('Révéler le mot du jour'));
  await tapAndSettle(tester, find.byType(ThemeChoiceTag).first);
}

/// Answers the quiz on screen, [rightAnswers] first right then wrong
Future<void> playQuiz(WidgetTester tester, {required int questions, int? rightAnswers}) async {
  for (var i = 0; i < questions; i++) {
    final word = FakeWords.all.firstWhere((w) => find.text(w.definition).evaluate().isNotEmpty);
    final right = rightAnswers == null || i < rightAnswers;
    final tags = find.byWidgetPredicate(
      (widget) => widget is Text && widget.data != null && FakeWords.all.any((w) => w.name == widget.data),
    );
    final answer = right
        ? find.text(word.name)
        : tags.evaluate().map((e) => find.text((e.widget as Text).data!)).firstWhere(
              (f) => (f.evaluate().first.widget as Text).data != word.name,
            );
    await tapAndSettle(tester, answer, const Duration(seconds: 3));
  }
}

/// The bookmark dialog shows [letter] as an unlocked Alphadex tile of [tier],
/// the same size as the grid's tiles, without the bookmark drawing nor title
void expectDialogLetter(WidgetTester tester, String letter, AlphabetTier tier) {
  final inDialog = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(LetterTile),
  );
  final tile = tester.widget<LetterTile>(inDialog);
  expect(tile.letter, letter);
  expect(tile.unlocked, isTrue);
  expect(tile.tier, tier);

  final gridTile = find.byWidgetPredicate((w) => w is LetterTile && w.letter == 'A').first;
  expect(tester.getSize(inDialog), tester.getSize(gridTile));
  expect(find.text('Lettre $letter'), findsNothing);
  expect(
    find.descendant(of: find.byType(AlertDialog), matching: find.byType(BookmarkArt)),
    findsNothing,
  );
}

void main() {
  group('Chaque scénario s\'ouvre sans erreur', () {
    for (final scenario in DebugScenarios.all) {
      testWidgets(scenario.id, (tester) async {
        await pumpScenario(tester, scenario.id);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('streak_30 : le reveal donne le bonus de série et un skip', (tester) async {
    final backend = await pumpScenario(tester, 'streak_30');

    await revealFirstTheme(tester);
    await tapAndSettle(tester, find.text('Valider ce mot'));

    expect(find.text('Série de 30 jours !'), findsOneWidget);
    expect(find.text('+100 XP'), findsOneWidget);
    expect(backend.profile.currentStreak, 30);
    expect(backend.profile.nbSkip, 1);
  });

  testWidgets('level_5 : passage au niveau 5 avec un skip', (tester) async {
    final backend = await pumpScenario(tester, 'level_5');

    await revealFirstTheme(tester);
    await tapAndSettle(tester, find.text('Valider ce mot'));

    expect(find.textContaining('Niveau 5'), findsOneWidget);
    expect(backend.profile.level, 5);
    expect(backend.profile.nbSkip, 1);
  });

  testWidgets('no_skip : la pub récompensée donne un skip, une fois', (tester) async {
    final backend = await pumpScenario(tester, 'no_skip');

    await revealFirstTheme(tester);
    await tapAndSettle(tester, find.text('Regarder une pub : +1 skip'));

    expect(backend.profile.nbSkip, 1);
    expect(find.text('Regarder une pub : +1 skip'), findsNothing);
  });

  testWidgets('bookmark_assembly : le 7e fragment assemble un marque-page', (tester) async {
    final backend = await pumpScenario(tester, 'bookmark_assembly');

    await revealFirstTheme(tester);
    await tapAndSettle(tester, find.text('Valider ce mot'));

    expect(backend.profile.bookmarks, 1);
    expect(backend.profile.bookmarkFragments, 0);
  });

  testWidgets("alphadex_complete : le W complète l'Alphadex doré", (tester) async {
    final backend = await pumpScenario(tester, 'alphadex_complete');

    await revealFirstTheme(tester);
    expect(find.text('wapiti'), findsOneWidget);
    await tapAndSettle(tester, find.text('Valider ce mot'));

    expect(find.text('Alphadex doré complet !'), findsOneWidget);
    expect(backend.profile.tier, AlphabetTier.emerald);
  });

  testWidgets('errors : chaque échec affiche un message puis Réessayer marche', (tester) async {
    await pumpScenario(tester, 'errors');
    expect(find.text('Impossible de charger le mot du jour.'), findsOneWidget);

    await tapAndSettle(tester, find.text('Réessayer'));
    await tapAndSettle(tester, find.text('Révéler le mot du jour'));
    expect(find.text('Impossible de charger les thèmes.'), findsOneWidget);

    await tapAndSettle(tester, find.text('Réessayer'));
    await tapAndSettle(tester, find.byType(ThemeChoiceTag).first);
    expect(find.text('Impossible de révéler ce mot. Réessaie.'), findsOneWidget);

    await tapAndSettle(tester, find.byType(ThemeChoiceTag).first);
    expect(find.text('Valider ce mot'), findsOneWidget);
  });

  testWidgets('sunday_locked : pas assez de mots pour le quiz hebdo', (tester) async {
    await pumpScenario(tester, 'sunday_locked');

    expect(find.textContaining('Il faut au moins 3 mots'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
      find.ancestor(of: find.text('Commencer le quiz'), matching: find.byType(ElevatedButton)),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('sunday_quiz : un quiz parfait donne le bonus puis la carte résultat',
      (tester) async {
    final backend = await pumpScenario(tester, 'sunday_quiz');

    await tapAndSettle(tester, find.text('Commencer le quiz'));
    await playQuiz(tester, questions: 6);

    expect(find.text('Bravo !'), findsOneWidget);
    expect(find.text('Quiz parfait !'), findsOneWidget);
    expect(backend.profile.nbQuizWeeklyCompleted, 1);

    await tapAndSettle(tester, find.text('Terminer'));
    expect(find.text('Commencer le quiz'), findsNothing);
  });

  testWidgets('sunday_done : la card du quiz terminé montre le score, sans titre ni étoiles',
      (tester) async {
    await pumpScenario(tester, 'sunday_done');

    expect(find.text('Quiz terminé'), findsOneWidget);
    expect(find.text('5 / 6'), findsOneWidget);
    expect(find.text('Quiz hebdo'), findsNothing);
    expect(find.byType(QuizRatingStars), findsNothing);
  });

  testWidgets('quiz_resume : le quiz reprend à la question 4', (tester) async {
    await pumpScenario(tester, 'quiz_resume');

    await tester.tap(find.text('Commencer le quiz'));
    await settle(tester, const Duration(seconds: 1));

    expect(find.text('Reprise du quiz à la question 4'), findsOneWidget);
  });

  testWidgets('alphadex_bookmarks : un marque-page débloque une lettre grise', (tester) async {
    final backend = await pumpScenario(tester, 'alphadex_bookmarks');
    expect(backend.profile.hasLetter('Z'), isFalse);

    await tapAndSettle(
      tester,
      find.byWidgetPredicate((w) => w is LetterTile && w.letter == 'Z'),
    );
    expectDialogLetter(tester, 'Z', AlphabetTier.gold);
    await tester.tap(find.text('Débloquer'));
    await settle(tester, const Duration(seconds: 1));

    expect(find.text('Lettre Z débloquée ! +20 XP'), findsOneWidget);
    expect(backend.profile.hasLetter('Z'), isTrue);
    expect(backend.profile.bookmarks, 1);
  });

  testWidgets("emerald : la modale montre la lettre en émeraude", (tester) async {
    final backend = await pumpScenario(tester, 'emerald');
    expect(backend.profile.hasLetter('Z'), isFalse);

    await tapAndSettle(
      tester,
      find.byWidgetPredicate((w) => w is LetterTile && w.letter == 'Z'),
    );
    expectDialogLetter(tester, 'Z', AlphabetTier.emerald);
  });

  testWidgets('notebook : la recherche ignore les accents', (tester) async {
    await pumpScenario(tester, 'notebook');

    await tester.enterText(find.byType(TextField), 'ephemere');
    await settle(tester, const Duration(milliseconds: 300));

    expect(find.text('éphémère'), findsOneWidget);
    expect(find.text('1 mot(s)'), findsOneWidget);
  });
}
