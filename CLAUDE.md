# PauseDico

Application mobile (Flutter) d'apprentissage quotidien de mots du dictionnaire français.
Chaque jour, l'utilisateur découvre un « mot du jour » (nom, nature/genre, définition) tiré du Wiktionnaire.
Le dimanche, le « Quiz hebdo » porte sur les mots de la semaine. Tous les 30 jours (resp. 365) depuis l'inscription, un « Quiz du mois » (resp. « Quiz de l'année ») est débloqué si le user a révélé au moins 10 (resp. 50) mots sur la période. La feuille de route se trouve dans [TODO](TODO).

## Base de données Supabase

- Projet : `dekiorcmhkijfuiibohz` — URL : `https://dekiorcmhkijfuiibohz.supabase.co`
- La clé publishable, l'URL et les noms de tables sont dans [app_constants.dart](app/pause_dico/lib/core/constants/app_constants.dart). Ne pas les dupliquer ailleurs dans l'app.
- Le client est initialisé dans [main.dart](app/pause_dico/lib/main.dart) (`Supabase.initialize`), puis récupéré via `Supabase.instance.client`.
- Auth : Supabase Auth (email/mot de passe + Google OAuth). Liens de retour vers l'app : `io.supabase.pausedico://login-callback` (Google, confirmation d'email) et `io.supabase.pausedico://reset-callback` (mot de passe oublié → `ResetPasswordScreen`). Déclarés dans `AndroidManifest.xml` / `Info.plist` et à autoriser dans Supabase > Authentication > URL Configuration > Redirect URLs.
- Le MCP Supabase est disponible pour inspecter le schéma, lancer du SQL ou appliquer des migrations.

Tables (schéma `public`, RLS activé partout) :

| Table | Colonnes | Notes |
|---|---|---|
| `word` | `id` (bigint, PK), `name`, `gender` (toujours « n. »), `type` (ex. « nom féminin »), `theme` (ex. « Botanique », 651 thèmes), `definition`, `nb_likes`, `nb_skip`, `pick_weight` (float, défaut 100, min 1), `first_letter` (généré : 1re lettre sans accent, A–Z, indexé) | ~133 613 mots. `nb_likes` = nb de users qui likent le mot, `nb_skip` = nb de fois où il a été skippé. `pick_weight` = max(1, 100 + 0,5 × `nb_likes` − 0,5 × `nb_skip`) |
| `user` | `id` (uuid, PK → `auth.users.id`), `username`, `email`, `created_at`, `notif_time` (time), `dark_theme` | Profil applicatif. Le client ne peut modifier que `username`, `notif_time` et `dark_theme` (`created_at` fixe les échéances des quiz spéciaux). Créé par le trigger `handle_new_user` avec le username choisi à l'inscription |
| `user_game_profile` | `user_id` (PK → `user.id`), `xp` (0–14 700), `level` (généré depuis `xp`), `nb_words`, `nb_quiz_weekly/monthly/yearly_completed`, `nb_skip` (défaut 1), `current_streak`, `best_streak`, `last_reveal_date`, `letters_mask` (26 bits, A = bit 0 : lettres dorées des mots de l'historique), `gold_bookmark_mask` (lettres dorées débloquées par marque-page), `emerald_since` (date où l'Alphadex doré a été complété), `emerald_mask` (lettres d'émeraude des mots révélés après `emerald_since`), `emerald_bookmark_mask`, `bookmark_fragments` (0–6), `bookmarks`, `bookmarks_assembled`, `has_all_letters` / `has_all_emerald_letters` (générés) | Lecture seule côté client ; créé par le trigger `handle_new_user`. Les masques « mots » sont recalculés depuis l'historique au skip ; les masques « marque-page » ne sont jamais recalculés (pas de conflit) |
| `user_reward_event` | `user_id`, `source`, `ref`, `xp`, `skips`, `fragments`, `created_at` | PK (`user_id`, `source`, `ref`) : chaque récompense n'est donnée qu'une fois. Journal des récompenses |
| `quiz_session` | `id` (uuid), `user_id`, `kind`, `ref_date`, `word_ids`, `options` (jsonb), `answers`, `score`, `completed_at` | Quiz en cours / joués. Les bonnes réponses restent côté serveur. Accessible uniquement via les RPC |
| `user_word_history` | `user_id` → `user.id`, `word_id` → `word.id`, `date` (défaut `CURRENT_DATE`), `liked` | PK (`user_id`, `word_id`), unique (`user_id`, `date`). Lecture seule côté client. Jointure via `word:word!user_word_history_word_id_fkey(...)` |
| `user_special_quiz` | `user_id` → `user.id`, `kind` (`monthly` / `yearly`), `due_date`, `score`, `total`, `completed_at` | PK (`user_id`, `kind`, `due_date`). Quiz spéciaux complétés. Écriture via RPC uniquement |
| `user_daily_choice` | `user_id` → `user.id`, `date`, `word_ids` (bigint[3]), `mystery_word_id` | PK (`user_id`, `date`). Les 3 mots candidats proposés au user ce jour-là (non re-tirables). Accessible uniquement via les RPC |

Mot du jour : chaque user choisit parmi 3 candidats personnels, dont seul le thème est affiché.
Les 3 mots sont tirés côté serveur (`pick_daily_choices`) parmi les mots jamais eus par le user : tirage aléatoire pondéré par `pick_weight` (clés Efraimidis-Spirakis, un seul scan qui garde les 50 meilleures clés), puis passe gloutonne garantissant 3 thèmes différents.
Au plus une fois tous les 7 jours, l'un des 3 est une « lettre mystère » : un mot commençant par une lettre pas encore découverte par le user.

Gamification (tout est calculé côté serveur, dans les RPC ci-dessous, via `grant_reward`) :
- Niveaux : passer du niveau n à n+1 coûte 50 + 10n XP (niveau L atteint à 5L² + 45L − 50 XP : niveau 2 à 60 XP, donc pas dès le 1er reveal), plafond niveau 50 à 14 700 XP, plus d'XP ensuite. Titres dans `LevelService`.
- Skips (règles dans `skip_rules`) : stock plafonné à 3 (un stock déjà au-dessus est conservé, mais plus rien n'est gagné), +1 skip tous les 5 niveaux (5, 10… 50), +1 skip par pub récompensée (1 fois par jour, `claim_ad_skip`).
- Reveal du mot du jour : +10 XP. Série de reveals consécutifs (le dimanche, jour du Quiz hebdo sans mot du jour, ne casse pas la série : `is_next_reveal_day`) : 3 j +15 XP, 7 j +30 XP, 30 j +100 XP +1 skip, tous les 100 j +300 XP +3 skips.
- Alphadex (`unlock_letter`), en deux paliers. Doré : nouvelle lettre (1re lettre d'un mot révélé ou skippé, ou marque-page) +20 XP ; les 26 : +500 XP, et l'Alphadex d'émeraude commence (`emerald_since`). Émeraude : on recommence les 26 lettres avec les mots révélés après `emerald_since`, +30 XP par lettre, +750 XP pour les 26. Une fois en émeraude, fragments, marque-pages et lettres sont nommés « d'émeraude » (`AlphabetTier`). La lettre mystère vise une lettre manquante du palier en cours (`active_letters_mask`).
- Marque-pages (règles dans `bookmark_rules`) : 5 % de chance de trouver un fragment à chaque reveal ; 7 fragments s'assemblent automatiquement en 1 marque-page (dans `grant_reward`, paramètre `p_fragments`). Un marque-page débloque une lettre grise du palier en cours (`use_bookmark`).
- Mots débloqués (`nb_words`, mots révélés hors skips) : tous les 50 mots, +100 XP et +1 fragment (récompense `words_milestone`).
- Quiz hebdo : au moins 3 mots dans la semaine ; les quiz des semaines passées sont rejouables mais ne rapportent rien.
- Quiz (1er passage de chaque quiz uniquement, score calculé par le serveur) : par bonne réponse hebdo / mois / année +5 / +7 / +10 XP, quiz parfait +20 / +50 / +150 XP. Règles dans `quiz_rules`.
- Un like ou un skip n'est jamais récompensé (ils influencent `pick_weight` pour tous).

Toutes les écritures passent par des RPC (security definer) :
- `get_daily_choices(p_date)` : renvoie les 3 candidats `[{id, theme}]` (la lettre mystère n'est jamais signalée au client), tirés une fois par jour et stockés dans `user_daily_choice`.
- `reveal_daily_word(p_date, p_word_id)` : enregistre le candidat choisi dans l'historique (idempotent, refuse un mot hors des choix), incrémente `nb_words`, donne les récompenses (reveal, série, lettre, palier de mots, fragment), renvoie `{word, nb_skip, liked, rewards: {events, profile}}`.
- `skip_daily_word(p_date)` : consomme un skip (`nb_skip`) et remplace le mot du jour par un mot aléatoire jamais vu (retire le like éventuel, incrémente `word.nb_skip` du mot remplacé et recalcule son `pick_weight`). `letters_mask` (et `emerald_mask`) est recalculé depuis l'historique sans le mot skippé (`history_letters_mask`) : sa lettre est reperdue si aucun autre mot ne la porte (sans reprendre l'XP ; la récompense d'une lettre n'est jamais redonnée). Le nouveau mot peut débloquer une lettre. Renvoie aussi `rewards`.
- `get_pending_special_quizzes(p_date)` : quiz du mois / de l'année en attente `[{kind, due_date}]`. Calculé à la volée (`special_quiz_due_date` : dernière échéance inscription + k × période où le user avait assez de mots), donc un quiz reste disponible tant qu'il n'est pas complété, même si le user ne s'est pas connecté le jour J.
- `start_quiz(p_date, p_kind, p_ref_date)` : reprend la session non terminée de ce quiz s'il y en a une (mêmes questions, réponses déjà données, `answered` / `score` : anti-triche, on ne peut pas recommencer pour réessayer), sinon crée une `quiz_session` (hebdo : dimanche `p_ref_date`, mots du lundi au samedi ; mois / année : échéance en attente, mots au hasard sur la période, likés en priorité). Renvoie les questions (définition, thème du mot en indice, options) sans les réponses. Nombre de questions : hebdo 6, mois 15, année 50 (`quiz_rules.nb_words`). Au-delà de 10 mots (mois / année), chaque question propose le bon mot + 9 autres.
- `get_quiz_result(p_kind, p_ref_date)` : score du 1er passage terminé d'un quiz (`{score, total, completed_at}`, null sinon). Un quiz terminé n'est plus rejouable depuis l'app : la card du Quiz hebdo affiche son résultat (`QuizDoneCard`).
- `answer_quiz_question(p_session_id, p_index, p_word_id)` : répond aux questions dans l'ordre, renvoie la bonne réponse ; à la dernière, calcule le score, donne les récompenses du 1er passage et marque le quiz spécial comme complété (`user_special_quiz`).
- `can_claim_ad_skip(p_date)` / `claim_ad_skip(p_date)` : pub récompensée regardée → +1 skip (récompense `source = 'ad'`, `ref` = date : une fois par jour, et seulement sous le plafond du stock). Le client appelle `claim_ad_skip` après le callback « reward » du SDK AdMob ; une vérification côté serveur (SSV AdMob → Edge Function) reste à faire pour bloquer un appel direct.
- `use_bookmark(p_date, p_letter)` : consomme un marque-page pour débloquer une lettre grise du palier en cours (bit dans `gold_bookmark_mask` ou `emerald_bookmark_mask`), donne la récompense de la lettre (et éventuellement de l'Alphadex complet). Renvoie `{events, profile}`.
- `set_word_liked(p_word_id, p_liked)` : like / unlike (idempotent), recalcule `nb_likes` et `pick_weight` sous verrou de ligne (pas de mise à jour perdue en concurrence), renvoie l'état enregistré.
- `delete_my_account()` : supprime définitivement le compte (`auth.users`, tout le reste suit par cascade), puis recalcule `nb_likes` / `pick_weight` des mots que le user likait. Bouton « Supprimer mon compte » du profil (exigé par Google Play). Règles de confidentialité publiées depuis [docs/index.html](docs/index.html) (GitHub Pages ; section `#suppression` = URL de suppression des données de la Play Console).

## Architecture

```
app/pause_dico/          App Flutter
  lib/
    main.dart            Init Supabase / notifications / thème, locale fr, AuthGate
    core/
      constants/         Constantes (credentials Supabase, noms de tables / RPC, clés de cache…)
      theme/             AppTheme (clair/sombre) + ThemeSwitcher, TierColors (or / émeraude)
      utils/             Helpers génériques (DateHelpers — dates calendaires, sûres aux
                         changements d'heure —, TextHelpers, TimePickerHelpers, context.showSnackBar…)
    models/              Types d'objets avec fromJson/toJson (mots, profil de jeu, récompenses, quiz…)
    repositories/        Accès Supabase (auth, user, profil de jeu, historique, quiz)
    services/            Logique hors Supabase : AdService (AdMob : consentement UMP, bannière
                         adaptative en bas de la home, pub récompensée « +1 skip » ; ids de TEST
                         dans AppConstants / AndroidManifest.xml / Info.plist, à remplacer avant
                         publication), NotificationService (rappels des 14 prochains
                         jours, reprogrammés à chaque ouverture / reveal), ThemeService, LevelService,
                         OnboardingService, PronunciationService (TTS), WordShareService
    screens/             Écrans (auth_gate, auth, reset_password, onboarding, home, user, quiz,
                         alphabet, notebook) : orchestrent l'état
    debug/               Scénarios de test (debug uniquement) : FakeBackend en mémoire,
                         catalogue de scénarios, menu
    widgets/             Petits composants réutilisables (AppLogo, FeatureCard, WordCard…)
  assets/icons/          Logo et icônes utilisés dans l'app (déclarés dans pubspec.yaml)
  assets/launcher/       Sources des icônes de l'app (non embarquées)
data/                    Scripts Python de génération et d'import du dictionnaire
  generate_dico.py       Extraction des mots/définitions depuis le Wiktionnaire → pause_dico.json
  add_types.py           Ajout de la nature grammaticale via l'API Wiktionnaire
  json_to_supabase.py    Import (upsert par lots) de pause_dico.json dans la table `word`
```

Commandes utiles (depuis `app/pause_dico/`) :

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter run --dart-define=SCENARIO=menu   # scénarios de test (données simulées)
flutter pub run flutter_launcher_icons   # régénère les icônes depuis assets/launcher/
flutter build apk --release              # signé avec android/key.properties s'il existe
```

## Tests et scénarios de debug

Pour tester une feature sans se connecter, sans enchaîner les étapes et sans toucher à la base :

- **Scénarios** (`lib/debug/`) : chaque `DebugScenario` de [debug_scenarios.dart](app/pause_dico/lib/debug/debug_scenarios.dart) décrit une situation prête à l'emploi (série de 29 jours, 25 lettres dorées, dimanche de quiz, quiz du mois en attente, erreurs réseau…). En debug seulement :
  - `flutter run --dart-define=SCENARIO=menu` : liste de tous les scénarios (retour = menu, chaque ouverture repart de zéro) ;
  - `flutter run --dart-define=SCENARIO=streak_30` : ouvre directement ce scénario.
  Supabase n'est jamais initialisé dans ce mode. Ça tourne aussi sur le web (`-d chrome`) quand aucun émulateur n'est disponible.
- **Comment ça marche** : les écrans récupèrent leurs repositories via `Repositories.xxx()` ([repositories.dart](app/pause_dico/lib/repositories/repositories.dart)), jamais `XxxRepository()` directement. Un scénario y branche un `FakeBackend` en mémoire ([fake_backend.dart](app/pause_dico/lib/debug/fake_backend.dart)), qui implémente tous les repositories et rejoue les règles du serveur (reveal, série, lettres, marque-pages, quiz). **Si une règle change dans les RPC SQL, mettre à jour `_Rules` et le `FakeBackend`.** `FakeSeed` génère l'historique et le profil à partir de quelques chiffres.
- **Date** : toujours `AppClock.now()` / `AppClock.today()`, jamais `DateTime.now()` (un scénario déplace l'horloge, par exemple à un dimanche).
- **Effets externes** : quand `AppEnvironment.simulated` est vrai, les pubs (`AdService`, `AdSlot`) et les notifications (`NotificationService`) sont simulées. Les rappels réels du téléphone ne sont pas touchés.
- **Tests** (`flutter test`) : [scenarios_test.dart](app/pause_dico/test/scenarios_test.dart) ouvre chaque scénario puis joue les parcours clés via `pumpScenario` ([scenario_harness.dart](app/pause_dico/test/helpers/scenario_harness.dart)) ; [game_rules_test.dart](app/pause_dico/test/game_rules_test.dart) teste la logique pure (niveaux, série, dates). Pour couvrir une nouvelle feature : ajouter un scénario, puis un test qui l'ouvre.

Release Android : identifiant `com.toutai.pausedico` (`applicationId`, imposé par la Play Console ; le `namespace` / package Kotlin reste `com.pausedico.app`). La signature lit `android/key.properties` (modèle : `key.properties.example`, fichier et keystore ignorés par git) ; sans lui, la release est signée avec la clé de debug.

## Coding style (à respecter dans ce repo)

- **Modèles** : tout type d'objet métier va dans `lib/models/`, un fichier par modèle (`xxx_model.dart`), avec `fromJson` / `toJson`. Pas de classes de données déclarées dans un screen ou un service.
- **Services** : toute logique d'accès aux données ou métier va dans un service dédié (`lib/repositories/` pour l'accès Supabase, `lib/services/` pour le reste). Les screens n'appellent jamais `Supabase.instance.client` directement.
- **Factoriser** : pas de code dupliqué. Une logique répétée (formatage de dates, requêtes, styles…) est extraite dans un helper (`lib/core/utils/`), un service ou un widget réutilisable. Utiliser les constantes de `AppConstants` plutôt que des valeurs en dur.
- **Petits widgets** : privilégier de petits composants réutilisables placés dans `lib/widgets/`, assemblés dans les screens. Un screen doit rester lisible : il orchestre l'état et compose des widgets, il ne contient pas de longs arbres de widgets imbriqués.
- Suivre les lints de `flutter_lints` (`flutter analyze` sans warning).
