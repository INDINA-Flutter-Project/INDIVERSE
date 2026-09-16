import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.vx,
    required this.vy,
    required this.alpha,
    required this.depth,
    required this.color,
  });

  double x;
  double y;
  double radius;
  double vx;
  double vy;
  double alpha;
  double depth;
  Color color;
}

class ParticleCanvas extends StatefulWidget {
  const ParticleCanvas({super.key, this.dragOffset = 0});

  final double dragOffset;

  @override
  State<ParticleCanvas> createState() => _ParticleCanvasState();
}

class _ParticleCanvasState extends State<ParticleCanvas>
    with SingleTickerProviderStateMixin {
  static const _green = Color(0xFF1ED87A);
  static const _teal = Color(0xFF0ECBAD);

  final _particles = <Particle>[];
  final _random = Random();
  late final Ticker _ticker;
  Size _size = Size.zero;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _spawn() {
    if (_size.isEmpty) return;
    _particles
      ..clear()
      ..addAll(
        List.generate(28, (index) {
          return Particle(
            x: _random.nextDouble() * _size.width,
            y: _random.nextDouble() * _size.height,
            radius: 1.2 + _random.nextDouble() * 2.2,
            vx: (_random.nextDouble() - .5) * .45,
            vy: -(.18 + _random.nextDouble() * .38),
            alpha: .2 + _random.nextDouble() * .45,
            depth: .06 + _random.nextDouble() * .28,
            color: index % 3 == 0 ? _teal : _green,
          );
        }),
      );
  }

  void _tick(Duration elapsed) {
    if (_size.isEmpty) return;
    final elapsedMs = _lastTick == Duration.zero
        ? 16.67
        : (elapsed - _lastTick).inMicroseconds / 1000;
    _lastTick = elapsed;
    final frameScale = (elapsedMs / 16.67).clamp(.25, 3.0);

    for (final particle in _particles) {
      particle.x +=
          (particle.vx + widget.dragOffset * particle.depth * 3.5) * frameScale;
      particle.vy -= .002 * frameScale;
      if (particle.vy < -.65) {
        particle.vy = -(.18 + _random.nextDouble() * .32);
      }
      particle.y += particle.vy * frameScale;
      if (particle.y < -8) {
        particle
          ..y = _size.height + 5
          ..x = _random.nextDouble() * _size.width
          ..vy = -(.18 + _random.nextDouble() * .35);
      }
      if (particle.x < -12) particle.x = _size.width + 10;
      if (particle.x > _size.width + 12) particle.x = -10;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final nextSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (nextSize != _size) {
            _size = nextSize;
            _spawn();
          }
          return CustomPaint(
            size: _size,
            painter: ParticlePainter(_particles, widget.dragOffset),
          );
        },
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  const ParticlePainter(this.particles, this.dragOffset);

  final List<Particle> particles;
  final double dragOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.2),
          radius: .75,
          colors: [Color(0x111ED87A), Color(0x001ED87A)],
        ).createShader(rect),
    );

    final dragging = dragOffset.abs() > .01;
    for (final particle in particles) {
      final center = Offset(particle.x, particle.y);
      final alpha = (particle.alpha + (dragging ? .35 : 0)).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        particle.radius * 4,
        Paint()
          ..shader =
              RadialGradient(
                colors: [
                  particle.color.withValues(alpha: alpha * .7),
                  particle.color.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromCircle(center: center, radius: particle.radius * 4),
              ),
      );
      canvas.drawCircle(
        center,
        particle.radius,
        Paint()..color = particle.color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
