import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Developer/developer_shell.dart';
import '../player/player_shell.dart';
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
      duration: const Duration(milliseconds: 3600),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _continueToNextScreen();
    });
  }

  void _continueToNextScreen() {
    if (!mounted || _continued) return;
    _continued = true;

    final session = Supabase.instance.client.auth.currentSession;
    final role =
        Supabase.instance.client.auth.currentUser?.userMetadata?['role'];

    final Widget destination;
    if (session != null && role == 'developer') {
      destination = const DeveloperShell();
    } else if (session != null && role == 'user') {
      destination = const PlayerShell();
    } else {
      destination = const OnboardingScreen();
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
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
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _continueToNextScreen,
        child: Stack(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.12),
                  radius: 1.1,
                  colors: [Color(0x2922D17E), Colors.transparent],
                ),
              ),
              child: SizedBox.expand(),
            ),
            if (!reduceMotion)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) =>
                    _BackgroundParticles(progress: _controller.value),
              ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final entrance = Curves.easeOutCubic.transform(
                    (_controller.value / 0.24).clamp(0.0, 1.0),
                  );
                  final shine = Curves.easeInOutCubic.transform(
                    ((_controller.value - 0.28) / 0.42).clamp(0.0, 1.0),
                  );

                  return Opacity(
                    opacity: entrance,
                    child: Transform.scale(
                      scale: 0.86 + (0.14 * entrance),
                      child: Container(
                        width: MediaQuery.sizeOf(
                          context,
                        ).width.clamp(190.0, 320.0),
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x6622D17E),
                              blurRadius: 48,
                              spreadRadius: -8,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/images/indiverse_wordmark.png'),
                            if (!reduceMotion)
                              ShaderMask(
                                blendMode: BlendMode.srcATop,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment(-2.4 + shine * 4.8, -1),
                                    end: Alignment(-1.4 + shine * 4.8, 1),
                                    colors: const [
                                      Colors.transparent,
                                      Colors.white,
                                      Colors.transparent,
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Image.asset(
                                  'assets/images/indiverse_wordmark.png',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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

class _Particle {
  const _Particle(this.x, this.y, this.size, this.color, this.dx, this.dy);

  final double x;
  final double y;
  final double size;
  final Color color;
  final double dx;
  final double dy;
}
