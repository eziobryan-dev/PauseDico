import 'package:flutter/material.dart';

import '../widgets/onboarding_page.dart';

/// Welcome screens shown once, explaining how the app works
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    OnboardingPage(
      emoji: '🎯',
      title: 'Un mot par jour',
      text: 'Chaque jour, Pause Dico te propose de découvrir un nouveau mot !\n'
          '3 thèmes te seront proposés, mais 1 seul tu choisiras.',
    ),
    OnboardingPage(
      emoji: '🔥',
      title: 'Ta série',
      text: 'Révèle ton mot chaque jour pour faire grandir ta série et gagner des bonus.',
    ),
    OnboardingPage(
      emoji: '🧠',
      title: 'Les quiz',
      text: 'Tous les dimanches, c’est l’heure du Quiz.\n'
          'Rien de mieux que de revenir sur ses acquis !',
    ),
    OnboardingPage(
      emoji: '⭐',
      title: 'XP et niveaux',
      text: 'Gagne de l’XP pour monter de niveau, et gravis les échelons !',
    ),

  ];

  final PageController _controller = PageController();
  int _page = 0;

  bool get _isLastPage => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLastPage) {
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Visibility(
                visible: !_isLastPage,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: TextButton(
                  onPressed: widget.onDone,
                  child: const Text('Passer'),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_isLastPage ? "C'est parti !" : 'Suivant'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
