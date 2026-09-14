import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/text_styles.dart';
import '../authentication_screens/login_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const _green = Color(0xFF22D17E);
  static const _silver = Color(0xFFE7ECEA);
  static const _muted = Color(0xFF8A9490);

  static const _pages = [
    _OnboardingPage(
      title: 'Find your next favorite game',
      body:
          'Browse indie games from Saudi studios — from early builds to full release.',
      primary: _green,
      secondary: _silver,
    ),
    _OnboardingPage(
      title: 'Every build tells a story',
      body:
          'Developers share progress, milestones, and devlogs as their games take shape.',
      primary: _silver,
      secondary: _green,
    ),
    _OnboardingPage(
      title: 'Bridge to your audience',
      body:
          'Get matched with streamers and creators who bring your game to players.',
      primary: _green,
      secondary: _silver,
    ),
  ];

  final _pageController = PageController();
  late final AnimationController _orbitController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D0C),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/indiverse_icon.png', height: 24),
                  if (!isLast)
                    Positioned(
                      right: 20,
                      child: TextButton(
                        onPressed: () => _goToPage(_pages.length - 1),
                        child: Text(
                          'Skip',
                          style: AppTextStyles.interface.copyWith(
                            color: _muted,
                            fontSize: 13,
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
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) => _PageContent(
                  page: _pages[index],
                  orbitAnimation: reduceMotion
                      ? const AlwaysStoppedAnimation(0)
                      : _orbitController,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => GestureDetector(
                        onTap: () => _goToPage(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: index == _index ? 44 : 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: index == _index
                                ? _green
                                : Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isLast)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          colors: [_green, Color(0xFF0E8F57)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4022D17E),
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: _finish,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFF06170F),
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 17,
                          ),
                        ),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.chevron_right_rounded),
                        label: Text(
                          'Get started',
                          style: AppTextStyles.onboardingTitle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: () => _goToPage(_index + 1),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(48, 48),
                        backgroundColor: Colors.white.withValues(alpha: 0.045),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page, required this.orbitAnimation});

  final _OnboardingPage page;
  final Animation<double> orbitAnimation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: orbitAnimation,
            builder: (context, child) =>
                _Emblem(page: page, angle: orbitAnimation.value * math.pi * 2),
          ),
          const SizedBox(height: 34),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingTitle.copyWith(
              color: Color(0xFFF3F5F4),
              fontSize: 30,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: Text(
              page.body,
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingDetails.copyWith(
                color: _OnboardingScreenState._muted,
                fontSize: 18,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({required this.page, required this.angle});

  final _OnboardingPage page;
  final double angle;

  @override
  Widget build(BuildContext context) {
    const size = 210.0;
    final first = Offset(math.cos(angle) * 102, math.sin(angle) * 102);
    final second = Offset(
      math.cos(-angle * 0.74 + 2.1) * 118,
      math.sin(-angle * 0.74 + 2.1) * 118,
    );

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  page.primary.withValues(alpha: 0.19),
                  page.primary.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: page.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          Image.asset('assets/images/indiverse_mark.png', width: 125),
          Transform.translate(
            offset: first,
            child: _OrbitDot(color: page.primary, size: 10),
          ),
          Transform.translate(
            offset: second,
            child: _OrbitDot(color: page.secondary, size: 8),
          ),
        ],
      ),
    );
  }
}

class _OrbitDot extends StatelessWidget {
  const _OrbitDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 12)],
    ),
  );
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.primary,
    required this.secondary,
  });

  final String title;
  final String body;
  final Color primary;
  final Color secondary;
}
