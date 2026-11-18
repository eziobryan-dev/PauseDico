import '../core/utils/date_helpers.dart';
import '../models/quiz_result_model.dart';
import '../models/special_quiz_model.dart';
import 'debug_scenario.dart';
import 'fake_backend.dart';
import 'fake_seed.dart';
import 'fake_words.dart';

/// Catalogue of the debug scenarios, shown by the debug menu and replayed by
/// the widget tests. Add one per feature or edge case worth checking by hand.
abstract class DebugScenarios {
  /// Wednesday 18 November 2026, 10:00: a regular day with a daily word
  static final DateTime _wednesday = DateTime(2026, 11, 18, 10);

  /// Sunday 22 November 2026, 10:00: weekly quiz day
  static final DateTime _sunday = DateTime(2026, 11, 22, 10);

  static const _daily = 'Mot du jour';
  static const _rewards = 'Récompenses';
  static const _alphadex = 'Alphadex';
  static const _quiz = 'Quiz';
  static const _profile = 'Profil et carnet';

  static final List<DebugScenario> all = [
    // ------------------------------------------------------- Mot du jour
    DebugScenario(
      id: 'new_user',
      category: _daily,
      title: 'Nouveau compte',
      description: 'Aucun mot, niveau 1, 1 skip. Révèle le tout premier mot.',
      now: _wednesday,
      build: () => FakeSeed.backend(today: _wednesday, xp: 0),
    ),
    DebugScenario(
      id: 'daily',
      category: _daily,
      title: 'Mot du jour à révéler',
      description: 'Série de 12 jours. Choisis un thème, like, skip, puis '
          'navigue dans les jours passés (dont un jour sans mot).',
      now: _wednesday,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 12, olderWords: 5),
    ),
    DebugScenario(
      id: 'revealed',
      category: _daily,
      title: 'Mot déjà révélé',
      description: "Le mot d'aujourd'hui est affiché : like, partage, prononciation.",
      now: _wednesday,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 8, revealedToday: true),
    ),
    DebugScenario(
      id: 'no_skip',
      category: _daily,
      title: 'Plus de skip',
      description: '0 skip : « Regarder une pub : +1 skip » (pub simulée), '
          'une seule fois par jour.',
      now: _wednesday,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 6, nbSkip: 0),
    ),
    DebugScenario(
      id: 'errors',
      category: _daily,
      title: 'Erreurs réseau',
      description: 'Le 1er chargement, le chargement des thèmes, le reveal et '
          'le skip échouent une fois : vérifie les messages et « Réessayer ».',
      now: _wednesday,
      build: () => FakeSeed.backend(
        today: _wednesday,
        streakDays: 5,
        failures: {
          FakeFailure.loadWord: 1,
          FakeFailure.dailyChoices: 1,
          FakeFailure.reveal: 1,
          FakeFailure.skip: 1,
        },
      ),
    ),

    // -------------------------------------------------------- Récompenses
    DebugScenario(
      id: 'streak_30',
      category: _rewards,
      title: 'Série de 30 jours',
      description: 'Série de 29 jours : le prochain reveal donne +100 XP et +1 skip.',
      now: _wednesday,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 29, nbSkip: 0),
    ),
    DebugScenario(
      id: 'level_5',
      category: _rewards,
      title: 'Passage au niveau 5',
      description: '295 XP : le reveal fait passer niveau 5 (« Apprenti ») et donne +1 skip.',
      now: _wednesday,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 4, xp: 295, nbSkip: 0),
    ),
    DebugScenario(
      id: 'words_50',
      category: _rewards,
      title: '50e mot débloqué',
      description: '49 mots : le reveal déclenche le palier (+100 XP, +1 fragment).',
      now: _wednesday,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 10, nbWords: 49),
    ),
    DebugScenario(
      id: 'bookmark_assembly',
      category: _rewards,
      title: 'Marque-page assemblé',
      description: '6 fragments, et le prochain reveal en trouve un : '
          'animation du 7e fragment puis du marque-page.',
      now: _wednesday,
      build: () => FakeSeed.backend(
        today: _wednesday,
        streakDays: 9,
        fragments: 6,
        fragmentOnNextReveal: true,
      ),
    ),
    DebugScenario(
      id: 'alphadex_complete',
      category: _rewards,
      title: 'Dernière lettre dorée',
      description: '25 lettres sur 26 : le 1er thème proposé (Mammalogie) donne '
          'le W, complète l\'Alphadex doré et lance l\'émeraude.',
      now: _wednesday,
      build: () => FakeSeed.backend(
        today: _wednesday,
        streakDays: 25,
        historyWords: [
          for (final word in FakeWords.all.take(26))
            if (word.name != 'wapiti') word.name,
        ],
        poolFirst: ['wapiti'],
      ),
    ),

    // ----------------------------------------------------------- Alphadex
    DebugScenario(
      id: 'alphadex_bookmarks',
      category: _alphadex,
      title: 'Utiliser un marque-page',
      description: '2 marque-pages dorés : touche une lettre grise pour la débloquer.',
      now: _wednesday,
      start: ScenarioStart.alphabet,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 15, bookmarks: 2),
    ),
    DebugScenario(
      id: 'emerald',
      category: _alphadex,
      title: "Alphadex d'émeraude",
      description: "Alphadex doré complété il y a 12 jours : les lettres d'émeraude "
          'des mots révélés depuis, et 1 marque-page d\'émeraude.',
      now: _wednesday,
      start: ScenarioStart.alphabet,
      build: () => FakeSeed.backend(
        today: _wednesday,
        streakDays: 10,
        olderWords: 26,
        lettersMask: FakeSeed.allLettersMask,
        emeraldDaysAgo: 12,
        bookmarks: 1,
      ),
    ),

    // ---------------------------------------------------------------- Quiz
    DebugScenario(
      id: 'sunday_quiz',
      category: _quiz,
      title: 'Quiz hebdo à jouer',
      description: 'Dimanche, 6 mots dans la semaine : joue le quiz (6 questions).',
      now: _sunday,
      build: () => FakeSeed.backend(today: _sunday, streakDays: 6),
    ),
    DebugScenario(
      id: 'sunday_locked',
      category: _quiz,
      title: 'Quiz hebdo verrouillé',
      description: 'Dimanche, seulement 2 mots dans la semaine : bouton désactivé.',
      now: _sunday,
      build: () => FakeSeed.backend(today: _sunday, streakDays: 2),
    ),
    DebugScenario(
      id: 'sunday_done',
      category: _quiz,
      title: 'Quiz hebdo terminé',
      description: 'Dimanche, quiz déjà joué (5/6) : la carte affiche le résultat.',
      now: _sunday,
      build: () => FakeSeed.backend(
        today: _sunday,
        streakDays: 6,
        quizResults: {
          FakeBackend.quizKey(QuizKind.weekly, DateHelpers.dateOnly(_sunday)):
              const QuizResultModel(score: 5, total: 6),
        },
      ),
    ),
    DebugScenario(
      id: 'quiz_resume',
      category: _quiz,
      title: 'Reprise du quiz hebdo',
      description: 'Quiz commencé (3 réponses, 2 bonnes) : il reprend à la question 4.',
      now: _sunday,
      build: () => FakeSeed.backend(today: _sunday, streakDays: 6)
        ..seedQuizProgress(
          QuizKind.weekly,
          DateHelpers.dateOnly(_sunday),
          answered: 3,
          correct: 2,
        ),
    ),
    DebugScenario(
      id: 'past_week_quiz',
      category: _quiz,
      title: "Quiz d'une semaine passée",
      description: 'Reviens au dimanche 8 novembre : quiz rejouable, sans récompense.',
      now: _wednesday,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 15),
    ),
    DebugScenario(
      id: 'monthly',
      category: _quiz,
      title: 'Quiz du mois en attente',
      description: 'Icône lumineuse dans la barre : le quiz porte sur les mots du mois.',
      now: _wednesday,
      build: () => FakeSeed.backend(
        today: _wednesday,
        streakDays: 14,
        pendingQuizzes: [
          SpecialQuizModel(
            kind: QuizKind.monthly,
            dueDate: DateHelpers.addDays(DateHelpers.dateOnly(_wednesday), -2),
          ),
        ],
      ),
    ),
    DebugScenario(
      id: 'yearly',
      category: _quiz,
      title: "Quiz de l'année + du mois",
      description: 'Deux quiz spéciaux en attente : 10 propositions par question '
          'au-delà de 10 mots.',
      now: _wednesday,
      build: () => FakeSeed.backend(
        today: _wednesday,
        streakDays: 20,
        olderWords: 15,
        pendingQuizzes: [
          SpecialQuizModel(kind: QuizKind.yearly, dueDate: DateHelpers.dateOnly(_wednesday)),
          SpecialQuizModel(
            kind: QuizKind.monthly,
            dueDate: DateHelpers.addDays(DateHelpers.dateOnly(_wednesday), -5),
          ),
        ],
      ),
    ),

    // --------------------------------------------------- Profil et carnet
    DebugScenario(
      id: 'notebook',
      category: _profile,
      title: 'Carnet bien rempli',
      description: '30 mots dont des favoris : recherche sans accents, filtre Favoris.',
      now: _wednesday,
      start: ScenarioStart.notebook,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 20, olderWords: 10),
    ),
    DebugScenario(
      id: 'profile',
      category: _profile,
      title: 'Profil',
      description: 'Niveau 13, série de 9 jours : pseudo, thème sombre, rappel, déconnexion.',
      now: _wednesday,
      start: ScenarioStart.profile,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 9, xp: 1500),
    ),
    DebugScenario(
      id: 'max_level',
      category: _profile,
      title: 'Niveau maximum',
      description: 'Niveau 50 (14 700 XP) : barre pleine, plus d\'XP ensuite.',
      now: _wednesday,
      start: ScenarioStart.profile,
      build: () => FakeSeed.backend(today: _wednesday, streakDays: 3, xp: 14700),
    ),
    DebugScenario(
      id: 'onboarding',
      category: _profile,
      title: 'Onboarding',
      description: "Écrans d'accueil du premier lancement.",
      now: _wednesday,
      start: ScenarioStart.onboarding,
      build: () => FakeSeed.backend(today: _wednesday),
    ),
  ];

  static DebugScenario? byId(String id) =>
      all.where((scenario) => scenario.id == id).firstOrNull;
}
