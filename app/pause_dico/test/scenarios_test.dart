import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pause_dico/debug/debug_scenarios.dart';
import 'package:pause_dico/debug/fake_words.dart';
import 'package:pause_dico/models/alphabet_tier_model.dart';
import 'package:pause_dico/widgets/bookmark_art.dart';
import 'package:pause_dico/widgets/letter_tile.dart';
import 'package:pause_dico/widgets/quiz_rating_stars.dart';
import 'package:pause_dico/widgets/word_choice_tile.dart';

import 'helpers/scenario_harness.dart';

/// Opens the daily word: selects the first candidate, "Suivant", then the
/// word card shows its definition
Future<void> revealFirstWord(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('Révéler le mot du jour'));
  await tapAndSettle(tester, find.byType(WordChoiceTile).first);
  await tapAndSettle(tester, find.text('Suivant'));
}

/// The rewards after the word card
Future<void> continueToRewards(WidgetTester tester) =>
    tapAndSettle(tester, find.text('Suivant'));

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

  testWidgets('daily : les 3 mots sont visibles avec leur thème, « Suivant » attend un choix',
      (tester) async {
    final backend = await pumpScenario(tester, 'daily');
    final wordsBefore = backend.profile.nbWords;

    await tapAndSettle(tester, find.text('Révéler le mot du jour'));
    final tiles = tester.widgetList<WordChoiceTile>(find.byType(WordChoiceTile)).toList();
    expect(tiles, hasLength(3));
    for (final tile in tiles) {
      expect(find.text(tile.name), findsOneWidget);
      expect(find.text(tile.theme), findsOneWidget);
    }

    // Nothing selected yet: "Suivant" does nothing
    await tapAndSettle(tester, find.text('Suivant'));
    expect(find.byType(WordChoiceTile), findsNWidgets(3));
    expect(backend.profile.nbWords, wordsBefore);

    await tapAndSettle(tester, find.byType(WordChoiceTile).at(1));
    await tapAndSettle(tester, find.text('Suivant'));
    expect(find.byType(WordChoiceTile), findsNothing);
    expect(find.text(tiles[1].name), findsOneWidget);
    expect(backend.profile.nbWords, wordsBefore + 1);
  });

  testWidgets('daily : la pastille « Prochain quiz » ouvre la règle des quiz', (tester) async {
    await pumpScenario(tester, 'daily');

    // Wednesday: the weekly quiz is in 4 days
    expect(find.text('dans 4 jours'), findsOneWidget);
    await tapAndSettle(tester, find.text('Prochain quiz'));
    expect(find.text('Les quiz'), findsOneWidget);
    expect(find.text('Quiz hebdo : dans 4 jours'), findsOneWidget);
  });

  testWidgets('streak_30 : le reveal donne le bonus de série', (tester) async {
    final backend = await pumpScenario(tester, 'streak_30');

    await revealFirstWord(tester);
    await continueToRewards(tester);

    expect(find.text('Série de 30 jours !'), findsOneWidget);
    expect(find.text('+100 XP'), findsOneWidget);
    expect(backend.profile.currentStreak, 30);
  });

  testWidgets('level_5 : passage au niveau 5', (tester) async {
    final backend = await pumpScenario(tester, 'level_5');

    await revealFirstWord(tester);
    await continueToRewards(tester);

    expect(find.textContaining('Niveau 5'), findsOneWidget);
    expect(backend.profile.level, 5);
  });

  testWidgets('bookmark_assembly : le 7e fragment assemble un marque-page', (tester) async {
    final backend = await pumpScenario(tester, 'bookmark_assembly');

    await revealFirstWord(tester);
    await continueToRewards(tester);

    expect(backend.profile.bookmarks, 1);
    expect(backend.profile.bookmarkFragments, 0);
  });

  testWidgets("alphadex_complete : le W complète l'Alphadex doré", (tester) async {
    final backend = await pumpScenario(tester, 'alphadex_complete');

    await revealFirstWord(tester);
    expect(find.text('wapiti'), findsOneWidget);
    await continueToRewards(tester);

    expect(find.text('Alphadex doré complet !'), findsOneWidget);
    expect(backend.profile.tier, AlphabetTier.emerald);
  });

  testWidgets('errors : chaque échec affiche un message puis Réessayer marche', (tester) async {
    await pumpScenario(tester, 'errors');
    expect(find.text('Impossible de charger le mot du jour.'), findsOneWidget);

    await tapAndSettle(tester, find.text('Réessayer'));
    await tapAndSettle(tester, find.text('Révéler le mot du jour'));
    expect(find.text('Impossible de charger les mots du jour.'), findsOneWidget);

    await tapAndSettle(tester, find.text('Réessayer'));
    await tapAndSettle(tester, find.byType(WordChoiceTile).first);
    await tapAndSettle(tester, find.text('Suivant'));
    expect(find.text('Impossible de valider ce mot. Réessaie.'), findsOneWidget);

    await tapAndSettle(tester, find.text('Suivant'));
    expect(find.byType(WordChoiceTile), findsNothing);
    expect(find.text('Suivant'), findsOneWidget);
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

  testWidgets('profile : le bouton ⓘ ouvre la légende des ressources', (tester) async {
    await pumpScenario(tester, 'profile');

    await tapAndSettle(tester, find.byTooltip('Légende des ressources'));
    expect(find.text('Tes ressources'), findsOneWidget);
    expect(find.text('Série'), findsOneWidget);
    expect(find.text('Marque-pages'), findsOneWidget);
  });

  testWidgets('notebook : la recherche ignore les accents', (tester) async {
    await pumpScenario(tester, 'notebook');

    await tester.enterText(find.byType(TextField), 'ephemere');
    await settle(tester, const Duration(milliseconds: 300));

    expect(find.text('éphémère'), findsOneWidget);
    expect(find.text('1 mot(s)'), findsOneWidget);
  });
}
