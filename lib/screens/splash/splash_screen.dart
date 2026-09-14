import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _continued = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3700),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _continueToLogin();
    });
  }

  void _continueToLogin() {
    if (!mounted || _continued) return;
    _continued = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _continueToLogin,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.25,
              colors: [Color(0x1A22D17E), Color(0x0007080D)],
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final entrance = Curves.easeOutCubic.transform(
                  (_controller.value / 0.28).clamp(0.0, 1.0),
                );
                final shine = Curves.easeInOut.transform(
                  ((_controller.value - 0.31) / 0.46).clamp(0.0, 1.0),
                );
                final floatOffset = reduceMotion
                    ? 0.0
                    : math.sin(_controller.value * math.pi * 2) * 3;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: entrance,
                      child: Transform.translate(
                        offset: Offset(0, (1 - entrance) * 10 + floatOffset),
                        child: Transform.scale(
                          scale: 0.86 + (0.14 * entrance),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/indiverse_wordmark.png',
                                width: MediaQuery.sizeOf(
                                  context,
                                ).width.clamp(210.0, 330.0),
                              ),
                              if (!reduceMotion)
                                IgnorePointer(
                                  child: ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) => LinearGradient(
                                      begin: Alignment(-2.5 + shine * 5, -1),
                                      end: Alignment(-1.5 + shine * 5, 1),
                                      colors: const [
                                        Colors.transparent,
                                        Colors.white,
                                        Colors.transparent,
                                      ],
                                    ).createShader(bounds),
                                    child: Image.asset(
                                      'assets/images/indiverse_wordmark.png',
                                      width: MediaQuery.sizeOf(
                                        context,
                                      ).width.clamp(210.0, 330.0),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Opacity(
                      opacity: ((_controller.value - 0.16) / 0.24).clamp(
                        0.0,
                        0.7,
                      ),
                      child: const Text(
                        'tap to continue',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          color: Color(0xFF8A9490),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
