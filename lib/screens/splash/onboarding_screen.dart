import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/text_styles.dart';
import '../../core/widget/glass_action.dart';
import '../authentication_screens/login_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const _green = Color(0xFF22D17E);
  static const _greenDeep = Color(0xFF0E8F57);
  static const _silver = Color(0xFFE7ECEA);
  static const _ink = Color(0xFFF3F5F4);
  static const _muted = Color(0xFF8A9490);

  static const _pages = [
    _OnboardingPage(
      title: 'Find your next favorite game',
      body:
          'Browse indie games from Saudi studios - from early builds to full release.',
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
  late final AnimationController _animationController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index.clamp(0, _pages.length - 1),
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.08),
                  radius: 1.1,
                  colors: [Color(0x2922D17E), Colors.transparent],
                ),
              ),
              child: SizedBox.expand(),
            ),
            if (!reduceMotion)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) =>
                    _BackgroundParticles(progress: _animationController.value),
              ),
            Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/indiverse_icon.png',
                        height: 22,
                      ),
                      AnimatedOpacity(
                        opacity: isLast ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: TextButton(
                              onPressed: isLast
                                  ? null
                                  : () => _goToPage(_pages.length - 1),
                              child: Text(
                                'Skip',
                                style: AppTextStyles.interface.copyWith(
                                  color: _muted,
                                  fontSize: 13,
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
                    itemCount: _pages.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      return _PageContent(
                        page: _pages[index],
                        isActive: index == _index,
                        animation: reduceMotion
                            ? const AlwaysStoppedAnimation(0)
                            : _animationController,
                      );
                    },
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
                              width: index == _index ? 20 : 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 7),
                              decoration: BoxDecoration(
                                color: index == _index
                                    ? _green
                                    : Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: isLast
                            ? _GetStartedButton(onPressed: _finish)
                            : GlassAction(
                                key: const ValueKey('next'),
                                onPressed: () => _goToPage(_index + 1),
                                padding: const EdgeInsets.all(14),
                                child: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: _ink,
                                ),
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

class _PageContent extends StatelessWidget {
  const _PageContent({
    required this.page,
    required this.isActive,
    required this.animation,
  });

  final _OnboardingPage page;
  final bool isActive;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final angle = animation.value * math.pi * 2;
              final floatOffset = math.sin(angle) * 4;

              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: _Emblem(page: page, angle: angle),
              );
            },
          ),
          const SizedBox(height: 32),
          AnimatedOpacity(
            opacity: isActive ? 1 : 0.45,
            duration: const Duration(milliseconds: 260),
            child: _ShineText(text: page.title, active: isActive),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              page.body,
              textAlign: TextAlign.center,
              style: AppTextStyles.onboardingDetails.copyWith(
                color: _OnboardingScreenState._muted,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShineText extends StatelessWidget {
  const _ShineText({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.onboardingTitle.copyWith(
      color: _OnboardingScreenState._ink,
      fontSize: 21,
      height: 1.3,
      fontWeight: FontWeight.w600,
    );

    if (!active || MediaQuery.disableAnimationsOf(context)) {
      return Text(text, textAlign: TextAlign.center, style: baseStyle);
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment(-1.0, -0.5),
        end: Alignment(1.0, 0.5),
        colors: [
          _OnboardingScreenState._ink,
          Colors.white,
          _OnboardingScreenState._ink,
        ],
      ).createShader(bounds),
      child: Text(text, textAlign: TextAlign.center, style: baseStyle),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({required this.page, required this.angle});

  final _OnboardingPage page;
  final double angle;

  @override
  Widget build(BuildContext context) {
    const size = 148.0;
    final first = Offset(math.cos(angle) * 74, math.sin(angle) * 74);
    final second = Offset(
      math.cos(-angle * 0.74 + 2.1) * 62,
      math.sin(-angle * 0.74 + 2.1) * 62,
    );
    final third = Offset(
      math.cos(angle + math.pi / 2) * 50,
      math.sin(angle + math.pi / 2) * 50,
    );

    return SizedBox(
      width: 210,
      height: 210,
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
                  page.primary.withValues(alpha: 0.20),
                  page.primary.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
              border: Border.all(color: page.primary.withValues(alpha: 0.30)),
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              shape: BoxShape.circle,
              border: Border.all(color: page.primary.withValues(alpha: 0.18)),
            ),
          ),
          Image.asset('assets/images/indiverse_mark.png', width: size * 0.5),
          Transform.translate(
            offset: first,
            child: _OrbitDot(color: page.primary, size: 6),
          ),
          Transform.translate(
            offset: second,
            child: _OrbitDot(color: page.secondary, size: 5),
          ),
          Transform.translate(
            offset: third,
            child: _OrbitDot(color: page.primary, size: 3),
          ),
        ],
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('get-started'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        gradient: const LinearGradient(
          colors: [
            _OnboardingScreenState._green,
            _OnboardingScreenState._greenDeep,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4022D17E),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                  stops: const [0, 0.35, 1],
                ),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF06170F),
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: Text(
              'Get started',
              style: AppTextStyles.onboardingTitle.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundParticles extends StatelessWidget {
  const _BackgroundParticles({required this.progress});

  final double progress;

  static const _particles = [
    _Particle(0.46, 0.55, 3.8, Color(0xFF22D17E), -13.9, -17.8),
    _Particle(0.62, 0.76, 2.2, Color(0xFFE7ECEA), 8.5, -25.3),
    _Particle(0.94, 0.91, 3.3, Color(0xFF22D17E), 1.2, -25.0),
    _Particle(0.22, 0.27, 2.1, Color(0xFFE7ECEA), 0.8, -15.8),
    _Particle(0.50, 0.64, 2.9, Color(0xFF22D17E), 15.0, -14.7),
    _Particle(0.33, 0.26, 2.6, Color(0xFFE7ECEA), 15.2, -19.8),
    _Particle(0.11, 0.61, 3.6, Color(0xFFE7ECEA), 20.4, -13.9),
    _Particle(0.15, 0.28, 2.2, Color(0xFF22D17E), 2.6, -18.8),
    _Particle(0.57, 0.82, 2.4, Color(0xFFE7ECEA), -11.0, -23.0),
    _Particle(0.72, 0.89, 2.4, Color(0xFF22D17E), -3.5, -24.3),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        for (var i = 0; i < _particles.length; i++)
          _ParticleDot(
            particle: _particles[i],
            offset: math.sin((progress * math.pi * 2) + i) * 0.5 + 0.5,
            screenSize: size,
          ),
      ],
    );
  }
}

class _OrbitDot extends StatelessWidget {
  const _OrbitDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 10)],
      ),
    );
  }
}

class _ParticleDot extends StatelessWidget {
  const _ParticleDot({
    required this.particle,
    required this.offset,
    required this.screenSize,
  });

  final _Particle particle;
  final double offset;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: particle.x * screenSize.width + particle.dx * offset,
      top: particle.y * screenSize.height + particle.dy * offset,
      child: Container(
        width: particle.size,
        height: particle.size,
        decoration: BoxDecoration(
          color: particle.color.withValues(alpha: 0.42),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: particle.color, blurRadius: 5)],
        ),
      ),
    );
  }
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

class _Particle {
  const _Particle(this.x, this.y, this.size, this.color, this.dx, this.dy);

  final double x;
  final double y;
  final double size;
  final Color color;
  final double dx;
  final double dy;
}
