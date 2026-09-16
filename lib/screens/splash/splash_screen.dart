import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/particle_canvas.dart';
import '../Developer/developer_shell.dart';
import '../authentication_screens/login_selection_screen.dart';
import '../player/player_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _exitStart = 3400 / 4100;
  late final AnimationController _controller;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4100),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _openNext();
    });
  }

  void _leave() {
    if (_leaving) return;
    _leaving = true;
    if (_controller.value < _exitStart) _controller.value = _exitStart;
    _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _openNext() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    final Widget destination;
    if (session != null) {
      destination = Supabase.instance.client.auth.currentUser?.userMetadata?['role'] ==
              'developer'
          ? const DeveloperShell()
          : const PlayerShell();
    } else {
      final preferences = await SharedPreferences.getInstance();
      final onboardingSeen = preferences.getBool('onboarding_seen') ?? false;
      if (!onboardingSeen) await preferences.setBool('onboarding_seen', true);
      destination = onboardingSeen
          ? const LoginSelectionScreen()
          : const OnboardingScreen();
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, secondaryAnimation) =>
            destination,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return ClipRect(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.08, 0),
                end: Offset.zero,
              ).animate(curve),
              child: ScaleTransition(
                scale: Tween<double>(begin: .97, end: 1).animate(curve),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width * .62, 220.0);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _leave,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!reduceMotion) const ParticleCanvas(),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final entrance = Curves.easeOutExpo.transform(
                    ((_controller.value - 80 / 4100) / (900 / 4100)).clamp(
                      0.0,
                      1.0,
                    ),
                  );
                  final shimmer = Curves.easeOutExpo.transform(
                    ((_controller.value - 820 / 4100) / (2400 / 4100)).clamp(
                      0.0,
                      1.0,
                    ),
                  );
                  final exit = Curves.easeInOutCubic.transform(
                    ((_controller.value - _exitStart) / (700 / 4100)).clamp(
                      0.0,
                      1.0,
                    ),
                  );
                  return Opacity(
                    opacity: reduceMotion ? 1 : entrance * (1 - exit),
                    child: Transform.translate(
                      offset: Offset(0, reduceMotion ? 0 : 20 * (1 - entrance)),
                      child: Transform.scale(
                        scale: reduceMotion ? 1 : .88 + .12 * entrance,
                        child: SizedBox(
                          width: width,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/indiverse_logo.webp',
                                width: width,
                                filterQuality: FilterQuality.high,
                              ),
                              if (!reduceMotion)
                                ShaderMask(
                                  blendMode: BlendMode.srcATop,
                                  shaderCallback: (bounds) {
                                    final position = -2.8 + shimmer * 5.6;
                                    return LinearGradient(
                                      begin: Alignment(position - 1, -1),
                                      end: Alignment(position + 1, 1),
                                      colors: const [
                                        Colors.transparent,
                                        Color(0xFFFFFFFF),
                                        Colors.transparent,
                                      ],
                                      stops: const [.26, .50, .74],
                                    ).createShader(bounds);
                                  },
                                  child: Image.asset(
                                    'assets/images/indiverse_logo.webp',
                                    width: width,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                            ],
                          ),
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
