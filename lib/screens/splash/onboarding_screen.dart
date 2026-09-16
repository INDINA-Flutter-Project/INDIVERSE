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
      title: 'Find your next\nfavorite game',
      body: 'Browse indie games from Saudi studios — from early builds to full release.',
      primary: _green,
      secondary: _silver,
    ),
    _OnboardingPage(
      title: 'Every build\ntells a story',
      body: 'Developers share progress, milestones, and devlogs as their games take shape.',
      primary: _silver,
      secondary: _green,
    ),
    _OnboardingPage(
      title: 'Bridge to\nyour audience',
      body: 'Get matched with streamers and creators who bring your game to players.',
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
                        index: index,
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
    required this.index,
    required this.page,
    required this.isActive,
    required this.animation,
  });

  final int index;
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
                child: _Scene(index: index, progress: animation.value),
              );
            },
          ),
          const SizedBox(height: 18),
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

class _ShineText extends StatefulWidget {
  const _ShineText({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  State<_ShineText> createState() => _ShineTextState();
}

class _ShineTextState extends State<_ShineText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: widget.active ? 0 : 1,
    );
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _ShineText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.onboardingTitle.copyWith(
      color: _OnboardingScreenState._ink,
      fontSize: 21,
      height: 1.3,
      fontWeight: FontWeight.w600,
    );

    if (!widget.active || MediaQuery.disableAnimationsOf(context)) {
      return Text(widget.text, textAlign: TextAlign.center, style: baseStyle);
    }

    final lines = widget.text.split('\n');
    final total = widget.text.replaceAll('\n', '').length;
    var character = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final glyph in line.characters)
                Builder(
                  builder: (context) {
                    final position = character++;
                    return AnimatedBuilder(
                      animation: _controller,
                      child: Text(glyph, style: baseStyle),
                      builder: (context, child) {
                        final start = (position * .55 / math.max(total, 1))
                            .clamp(0.0, .55);
                        final value = Curves.easeOutCubic.transform(
                          ((_controller.value - start) / .42).clamp(0.0, 1.0),
                        );
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 8 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene({required this.index, required this.progress});

  final int index;
  final double progress;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    height: 160,
    child: CustomPaint(
      painter: _ScenePainter(index: index, progress: progress),
    ),
  );
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({required this.index, required this.progress});

  final int index;
  final double progress;

  static const green = Color(0xFF1ED87A);
  static const teal = Color(0xFF0ECBAD);
  static const silver = Color(0xFFC8D8D4);
  static const panel = Color(0xFF0D1F18);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * .51);
    canvas.drawCircle(
      c,
      72,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x3822D17E), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: 72)),
    );
    if (index == 0) _controller(canvas, c);
    if (index == 1) _timeline(canvas, c);
    if (index == 2) _network(canvas, c);
  }

  void _controller(Canvas canvas, Offset c) {
    final float = math.sin(progress * math.pi * 2) * 3;
    canvas.save();
    canvas.translate(0, float);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 96, height: 56),
      const Radius.circular(28),
    );
    canvas.drawRRect(body, Paint()..color = panel);
    canvas.drawRRect(
      body,
      Paint()
        ..color = green.withValues(alpha: .7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final p = Paint()..color = green.withValues(alpha: .8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + const Offset(-28, 10),
          width: 6,
          height: 16,
        ),
        const Radius.circular(3),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + const Offset(-28, 10),
          width: 16,
          height: 6,
        ),
        const Radius.circular(3),
      ),
      p,
    );
    final buttonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final entry in const [
      (Offset(32, 4), teal),
      (Offset(40, 12), green),
      (Offset(24, 12), silver),
    ]) {
      buttonPaint.color = entry.$2;
      canvas.drawCircle(c + entry.$1, 4, buttonPaint);
    }
    canvas.restore();
    for (var i = 0; i < 4; i++) {
      final a = progress * math.pi * 2 + i * math.pi / 2;
      final star = c + Offset(math.cos(a) * 68, math.sin(a) * 34);
      _star(canvas, star, i.isEven ? 4 : 3, i.isEven ? green : teal);
    }
  }

  void _timeline(Canvas canvas, Offset c) {
    final line = Paint()
      ..color = green.withValues(alpha: .35)
      ..strokeWidth = 1.5;
    canvas.drawLine(c + const Offset(-64, 0), c + const Offset(64, 0), line);
    const xs = [-54.0, -16.0, 22.0, 58.0];
    const labels = ['Concept', 'Alpha', 'Beta', 'Launch'];
    for (var i = 0; i < xs.length; i++) {
      final done = i < 2;
      final node = c + Offset(xs[i], 0);
      canvas.drawCircle(node, 9, Paint()..color = done ? green : panel);
      canvas.drawCircle(
        node,
        9,
        Paint()
          ..color = (done ? green : silver).withValues(alpha: done ? 1 : .5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      final card = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: node - const Offset(0, 28),
          width: 36,
          height: 20,
        ),
        const Radius.circular(5),
      );
      canvas.drawRRect(card, Paint()..color = panel);
      canvas.drawRRect(
        card,
        Paint()
          ..color = (done ? green : silver).withValues(alpha: done ? .7 : .3)
          ..style = PaintingStyle.stroke,
      );
      _text(
        canvas,
        labels[i],
        node - const Offset(0, 28),
        done ? green : silver.withValues(alpha: .5),
        7,
      );
      if (done) {
        canvas.drawPath(
          Path()
            ..moveTo(node.dx - 4, node.dy)
            ..lineTo(node.dx - 1, node.dy + 3)
            ..lineTo(node.dx + 5, node.dy - 4),
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _network(Canvas canvas, Offset c) {
    final nodes = <(Offset, String)>[
      (c + const Offset(0, -10), 'Dev'),
      (c + const Offset(-48, -36), 'Creator A'),
      (c + const Offset(50, -36), 'Creator B'),
      (c + const Offset(-60, 22), 'Streamer'),
      (c + const Offset(58, 22), 'Creator C'),
    ];
    for (var i = 1; i < nodes.length; i++) {
      canvas.drawLine(
        nodes[0].$1,
        nodes[i].$1,
        Paint()
          ..color = green.withValues(alpha: .3)
          ..strokeWidth = 1,
      );
      final signal = Offset.lerp(
        nodes[0].$1,
        nodes[i].$1,
        (progress * (1.1 + i * .13)) % 1,
      )!;
      canvas.drawCircle(signal, 2.5, Paint()..color = teal);
    }
    for (var i = 0; i < nodes.length; i++) {
      final radius = i == 0 ? 16.0 : 11.0;
      canvas.drawCircle(nodes[i].$1, radius, Paint()..color = panel);
      canvas.drawCircle(
        nodes[i].$1,
        radius,
        Paint()
          ..color = i == 0 ? green : teal
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 2 : 1.2,
      );
      _text(
        canvas,
        nodes[i].$2,
        nodes[i].$1,
        const Color(0xFFF0F5F3),
        i == 0 ? 6.5 : 5.5,
      );
    }
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final rr = i.isEven ? r : r * .4;
      final a = -math.pi / 2 + i * math.pi / 4;
      final p = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path..close(),
      Paint()..color = color.withValues(alpha: .8),
    );
  }

  void _text(
    Canvas canvas,
    String value,
    Offset center,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(color: color, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.index != index || oldDelegate.progress != progress;
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
