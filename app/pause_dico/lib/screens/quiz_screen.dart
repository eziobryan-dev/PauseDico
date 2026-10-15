import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/context_extensions.dart';
import '../core/utils/date_helpers.dart';
import '../models/quiz_answer_model.dart';
import '../models/quiz_option_model.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/quiz_session_model.dart';
import '../models/special_quiz_model.dart';
import '../repositories/quiz_repository.dart';
import '../widgets/feature_card.dart';
import '../widgets/quiz_answer_tag.dart';
import '../widgets/quiz_definition_card.dart';
import '../widgets/quiz_progress_header.dart';
import '../widgets/quiz_result_dialog.dart';
import '../widgets/screen_title.dart';

/// Quiz (weekly, monthly or yearly), played on the server: one definition at
/// a time, the user picks the matching word. The server keeps the answers,
/// scores the quiz and grants the rewards on the first completion only.
class QuizScreen extends StatefulWidget {
  final QuizKind kind;

  /// Sunday of a weekly quiz, or due date of a special quiz
  final DateTime refDate;

  const QuizScreen({super.key, required this.kind, required this.refDate});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizRepository _quizRepository = QuizRepository();

  QuizSessionModel? _session;
  bool _isLoading = true;
  String? _errorMessage;

  int _index = 0;
  int _score = 0;
  int _streak = 0;
  int? _answeredWordId;
  QuizAnswerModel? _answer;
  bool _isSubmitting = false;
  Timer? _nextQuestionTimer;

  QuizQuestionModel get _question => _session!.questions[_index];
  bool get _hasAnswered => _answeredWordId != null;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  @override
  void dispose() {
    _nextQuestionTimer?.cancel();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final session = await _quizRepository.startQuiz(
        widget.kind,
        widget.refDate,
        DateHelpers.dateOnly(DateTime.now()),
      );
      if (!mounted) return;
      setState(() {
        _session = session;
        // An unfinished quiz resumes where the user left it
        _index = session.answered;
        _score = session.score;
        _streak = 0;
        _answeredWordId = null;
        _answer = null;
      });
      if (session.isResumed) {
        context.showSnackBar(
          'Reprise du quiz à la question ${session.answered + 1}',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Impossible de lancer le quiz.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAnswer(QuizOptionModel option) async {
    if (_hasAnswered || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _answeredWordId = option.wordId;
    });

    try {
      final answer = await _quizRepository.answer(
        _session!.sessionId,
        _index,
        option.wordId,
      );
      if (!mounted) return;
      answer.isCorrect
          ? HapticFeedback.lightImpact()
          : HapticFeedback.heavyImpact();
      setState(() {
        _answer = answer;
        if (answer.isCorrect) {
          _score++;
          _streak++;
        } else {
          _streak = 0;
        }
      });
      _nextQuestionTimer =
          Timer(AppConstants.quizNextQuestionDelay, _goToNextQuestion);
    } catch (e) {
      if (!mounted) return;
      setState(() => _answeredWordId = null);
      context.showSnackBar("Réponse non envoyée, réessaie.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goToNextQuestion() {
    if (!mounted) return;
    final answer = _answer;
    if (answer != null && answer.finished) {
      _showResult(answer);
      return;
    }
    setState(() {
      _index++;
      _answeredWordId = null;
      _answer = null;
    });
  }

  Future<void> _showResult(QuizAnswerModel answer) async {
    final playAgain = await QuizResultDialog.show(
      context,
      QuizResultModel(
        score: answer.score ?? _score,
        total: answer.total ?? _session!.questions.length,
      ),
      rewards: answer.rewards,
      noRewardMessage: answer.pastWeek
          ? 'Les quiz des semaines passées ne rapportent pas de récompenses'
          : null,
    );
    if (!mounted) return;

    if (playAgain == true) {
      _startQuiz();
    } else {
      Navigator.of(context).pop();
    }
  }

  QuizAnswerState _stateOf(QuizOptionModel option) {
    final answer = _answer;
    if (answer == null) return QuizAnswerState.idle;
    if (option.wordId == answer.correctWordId) return QuizAnswerState.correct;
    if (option.wordId == _answeredWordId) return QuizAnswerState.wrong;
    return QuizAnswerState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(widget.kind.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage != null || _session == null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: FeatureCard(
          tone: FeatureCardTone.error,
          icon: Icons.error_outline,
          message: _errorMessage ?? 'Impossible de lancer le quiz.',
          actionLabel: 'Réessayer',
          actionIcon: Icons.refresh,
          onAction: _startQuiz,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuizProgressHeader(
            current: _index + 1,
            total: _session!.questions.length,
            score: _score,
            streak: _streak,
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: QuizDefinitionCard(
              key: ValueKey(_index),
              definition: _question.definition,
              theme: _question.theme,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 12,
            children: [
              for (final option in _question.options)
                QuizAnswerTag(
                  label: option.name,
                  state: _stateOf(option),
                  onTap: _hasAnswered ? null : () => _submitAnswer(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
