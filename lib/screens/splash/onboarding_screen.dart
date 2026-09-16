import 'package:flutter/material.dart';

import '../../core/constants/text_styles.dart';
import '../../painters/scene_connect_painter.dart';
import '../../painters/scene_discover_painter.dart';
import '../../painters/scene_showcase_painter.dart';
import '../../widgets/particle_canvas.dart';
import '../authentication_screens/login_selection_screen.dart';

const _green = Color(0xFF1ED87A);
const _ink = Color(0xFFF0F5F3);
const _muted = Color(0xFF6B7F7A);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _pages = <_PageData>[
    _PageData(
      title: 'Find your next\nfavorite game',
      body: 'Browse indie games from Saudi studios — from early builds to full release.',
    ),
    _PageData(
      title: 'Every build\ntells a story',
      body: 'Developers share progress, milestones, and devlogs as their games take shape.',
    ),
    _PageData(
      title: 'Bridge to\nyour audience',
      body: 'Get matched with streamers and creators who bring your game to players.',
    ),
  ];

  late final PageController _pageController;
  late final AnimationController _sceneController;
  late final AnimationController _revealController;
  late final AnimationController _logoController;
  int _currentPage = 0;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()..addListener(_onDrag);
    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  void _onDrag() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page ?? _currentPage.toDouble();
    final next = (page - _currentPage) * 2.2;
    if ((next - _dragOffset).abs() > .0001 && mounted) {
      setState(() => _dragOffset = next);
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _dragOffset = 0;
    });
    _revealController.forward(from: 0);
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page.clamp(0, _pages.length - 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
    );
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, secondaryAnimation) =>
            const LoginSelectionScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutExpo,
              ),
              child: child,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onDrag)
      ..dispose();
    _sceneController.dispose();
    _revealController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!reduceMotion) ParticleCanvas(dragOffset: _dragOffset),
            Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          final value = reduceMotion
                              ? 1.0
                              : Curves.easeOutExpo.transform(
                                  _logoController.value,
                                );
                          return Opacity(
                            opacity: value * .88,
                            child: Transform.translate(
                              offset: Offset(0, -6 * (1 - value)),
                              child: Transform.scale(
                                scale: .88 + .12 * value,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/indiverse_icon.webp',
                          height: 20,
                        ),
                      ),
                      Positioned(
                        right: 16,
                        child: IgnorePointer(
                          ignoring: isLast,
                          child: AnimatedOpacity(
                            opacity: isLast ? 0 : .7,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            child: TextButton(
                              onPressed: () => _goTo(_pages.length - 1),
                              child: Text(
                                'Skip',
                                style: AppTextStyles.interface.copyWith(
                                  color: _muted,
                                  fontSize: 13,
                                  letterSpacing: .52,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        index: index,
                        data: _pages[index],
                        active: index == _currentPage,
                        dragOffset: _dragOffset,
                        sceneAnimation: reduceMotion
                            ? const AlwaysStoppedAnimation(0)
                            : _sceneController,
                        revealAnimation: reduceMotion
                            ? const AlwaysStoppedAnimation(1)
                            : _revealController,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 40),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(_pages.length, (index) {
                          final active = index == _currentPage;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _goTo(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3.5,
                                vertical: 12,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutExpo,
                                width: active ? 22 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? _green
                                      : const Color(0x2EFFFFFF),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutExpo,
                        switchOutCurve: Curves.easeInOutCubic,
                        child: isLast
                            ? _StartButton(
                                key: const ValueKey('start'),
                                onPressed: _finish,
                              )
                            : _NextButton(
                                key: const ValueKey('next'),
                                onPressed: () => _goTo(_currentPage + 1),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.index,
    required this.data,
    required this.active,
    required this.dragOffset,
    required this.sceneAnimation,
    required this.revealAnimation,
  });

  final int index;
  final _PageData data;
  final bool active;
  final double dragOffset;
  final Animation<double> sceneAnimation;
  final Animation<double> revealAnimation;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(dragOffset * .08 * screenWidth, 0),
            child: AnimatedBuilder(
              animation: sceneAnimation,
              builder: (context, child) => CustomPaint(
                size: const Size(200, 160),
                painter: switch (index) {
                  0 => SceneDiscoverPainter(sceneAnimation.value),
                  1 => SceneShowcasePainter(sceneAnimation.value),
                  _ => SceneConnectPainter(sceneAnimation.value),
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          _StaggeredTitle(
            title: data.title,
            active: active,
            animation: revealAnimation,
          ),
          const SizedBox(height: 12),
          _RevealedBody(
            text: data.body,
            active: active,
            animation: revealAnimation,
          ),
        ],
      ),
    );
  }
}

class _StaggeredTitle extends StatelessWidget {
  const _StaggeredTitle({
    required this.title,
    required this.active,
    required this.animation,
  });

  final String title;
  final bool active;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final lines = title.split('\n');
    var characterIndex = 0;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        characterIndex = 0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final line in lines)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final character in line.characters)
                    _letter(character, characterIndex++),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _letter(String character, int index) {
    final startMs = index * 28;
    final value = !active
        ? 0.0
        : Curves.easeOutExpo.transform(
            ((animation.value * 1200 - startMs) / 380).clamp(0.0, 1.0),
          );
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 8 * (1 - value)),
        child: Text(
          character,
          style: AppTextStyles.onboardingTitle.copyWith(
            color: _ink,
            fontSize: 22,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RevealedBody extends StatelessWidget {
  const _RevealedBody({
    required this.text,
    required this.active,
    required this.animation,
  });

  final String text;
  final bool active;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = !active
            ? 0.0
            : Curves.easeOutExpo.transform(
                ((animation.value * 1200 - 420) / 500).clamp(0.0, 1.0),
              );
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 230),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.onboardingDetails.copyWith(
            color: _muted,
            fontSize: 13.5,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 46,
      child: Material(
        color: const Color(0x0DFFFFFF),
        shape: const CircleBorder(side: BorderSide(color: Color(0x1AFFFFFF))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Icon(Icons.chevron_right_rounded, color: _ink, size: 20),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_green, Color(0xFF0DA85E)],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x441ED87A),
            blurRadius: 28,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get started',
                  style: AppTextStyles.onboardingTitle.copyWith(
                    color: const Color(0xFF061A0F),
                    fontSize: 14,
                    letterSpacing: .28,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF061A0F),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageData {
  const _PageData({required this.title, required this.body});

  final String title;
  final String body;
}
