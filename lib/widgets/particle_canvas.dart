import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const _kGreen = Color(0xFF1ED87A);
const _kTeal = Color(0xFF0ECBAD);

class _Particle {
  _Particle({
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
  final double radius;
  final double vx;
  double vy;
  final double alpha;
  final double depth;
  final Color color;
}

/// Holds the mutable particle simulation state, independent of Flutter's
/// widget/element lifecycle. A [Ticker] steps it every frame; a painter
/// reads its [particles] directly rather than through `setState`.
class _ParticleField {
  _ParticleField({required this.dragOffset});

  double dragOffset;
  final List<_Particle> particles = [];
  final _random = math.Random();
  Duration _lastElapsed = Duration.zero;

  void spawn(Size size) {
    particles
      ..clear()
      ..addAll(
        List.generate(28, (i) {
          return _Particle(
            x: _random.nextDouble() * size.width,
            y: _random.nextDouble() * size.height,
            radius: 1.2 + _random.nextDouble() * 2.2,
            vx: (_random.nextDouble() - .5) * .45,
            vy: -(.18 + _random.nextDouble() * .38),
            alpha: .2 + _random.nextDouble() * .45,
            depth: .06 + _random.nextDouble() * .28,
            color: i % 3 == 0 ? _kTeal : _kGreen,
          );
        }),
      );
  }

  void step(Duration elapsed, Size size) {
    if (size.isEmpty || particles.isEmpty) return;
    final deltaMs = _lastElapsed == Duration.zero
        ? 16.67
        : (elapsed - _lastElapsed).inMicroseconds / 1000;
    _lastElapsed = elapsed;
    final frameScale = (deltaMs / 16.67).clamp(.25, 3.0);

    for (final p in particles) {
      p.x += (p.vx + dragOffset * p.depth * 3.5) * frameScale;
      p.vy -= .002 * frameScale;
      if (p.vy < -.65) p.vy = -(.18 + _random.nextDouble() * .32);
      p.y += p.vy * frameScale;

      if (p.y < -8) {
        p
          ..y = size.height + 5
          ..x = _random.nextDouble() * size.width
          ..vy = -(.18 + _random.nextDouble() * .35);
      }
      if (p.x < -12) p.x = size.width + 10;
      if (p.x > size.width + 12) p.x = -10;
    }
  }
}

/// A full-bleed, ignored-by-hit-testing particle backdrop.
///
/// [dragOffset] should track live swipe velocity (e.g. the delta between a
/// [PageController]'s reported page and the settled page, scaled up). While
/// non-zero, particles drift further per depth layer and glow brighter,
/// giving swipes a tactile parallax response; it eases back to 0 on release.
class ParticleCanvas extends StatefulWidget {
  const ParticleCanvas({super.key, this.dragOffset = 0});

  final double dragOffset;

  @override
  State<ParticleCanvas> createState() => _ParticleCanvasState();
}

class _ParticleCanvasState extends State<ParticleCanvas>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final _ParticleField _field;
  final _repaint = ValueNotifier<int>(0);
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _field = _ParticleField(dragOffset: widget.dragOffset);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_size.isEmpty) return;
    _field.step(elapsed, _size);
    _repaint.value++;
  }

  @override
  void didUpdateWidget(covariant ParticleCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    _field.dragOffset = widget.dragOffset;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final next = Size(constraints.maxWidth, constraints.maxHeight);
          if (next.width > 0 && next.height > 0 && next != _size) {
            _size = next;
            _field.spawn(_size);
          }
          return CustomPaint(
            size: _size,
            painter: _ParticlePainter(field: _field, repaint: _repaint),
          );
        },
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.field, required Listenable repaint})
    : super(repaint: repaint);

  final _ParticleField field;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.2),
          radius: 1.05,
          colors: [Color(0x0D1ED87A), Color(0x001ED87A)],
        ).createShader(rect),
    );

    final dragging = field.dragOffset.abs() > .01;
    for (final p in field.particles) {
      final center = Offset(p.x, p.y);
      final alpha = (p.alpha + (dragging ? .35 : 0)).clamp(0.0, 1.0);
      final haloRadius = p.radius * (dragging ? 4.6 : 4);

      canvas.drawCircle(
        center,
        haloRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              p.color.withValues(alpha: alpha * .7),
              p.color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: haloRadius)),
      );
      canvas.drawCircle(
        center,
        p.radius,
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => false;
}
