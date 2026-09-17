import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_palette.dart';

const _viewBox = Rect.fromLTWH(0, 0, 200, 160);

/// Page 1: a floating game controller, orbited by stars and sparkles.
/// `progress` is a 0..1 sawtooth from a 12s-repeating [AnimationController],
/// matching the CSS scene's 12s loop; individual motifs derive their own
/// period by scaling that cycle (e.g. a 4s float is `progress * 12 / 4`).
class SceneDiscoverPainter extends CustomPainter {
  const SceneDiscoverPainter(this.progress);

  final double progress;

  double _cycles(double periodSeconds) => progress * 12 / periodSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    withViewBox(canvas, size, _viewBox, (canvas) {
      const center = Offset(100, 82);
      final glowRect = Rect.fromCenter(center: center, width: 144, height: 108);
      canvas.drawOval(
        glowRect,
        Paint()
          ..shader = RadialGradient(
            colors: [kGreen.withValues(alpha: .22), kGreen.withValues(alpha: 0)],
          ).createShader(glowRect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      final floatY = math.sin(_cycles(4) * math.pi * 2) * 7;
      canvas.save();
      canvas.translate(0, floatY);
      _controller(canvas);
      canvas.restore();

      _orbitStar(canvas, center, 68, 9, kGreen, .7, reverse: false);
      _orbitCircle(canvas, center, 58, 6, kTeal, .8);
      _orbitStarScaled(canvas, center, 11);

      _sparkle(canvas, const Offset(48, 54), 2, 0, 2);
      _sparkle(canvas, const Offset(156, 60), 1.5, .4, 2.6);
      _sparkle(canvas, const Offset(102, 38), 1.5, .8, 1.8);
    });
  }

  void _controller(Canvas canvas) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(52, 62, 96, 56),
      const Radius.circular(28),
    );
    canvas.drawRRect(body, Paint()..color = kCard);
    canvas.drawRRect(
      body,
      Paint()
        ..color = kGreen.withValues(alpha: .7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final dpad = Paint()..color = kGreen.withValues(alpha: .8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(68, 86, 6, 16),
        const Radius.circular(3),
      ),
      dpad,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(63, 91, 16, 6),
        const Radius.circular(3),
      ),
      dpad,
    );

    _ring(canvas, const Offset(132, 86), 4, kTeal, 1.5, 1);
    _ring(canvas, const Offset(140, 94), 4, kGreen, 1.5, 1);
    _ring(canvas, const Offset(124, 94), 4, kSilver, 1.5, 1);
    _ring(canvas, const Offset(132, 102), 4, kTeal, .8, .5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(97, 82, 6, 16),
        const Radius.circular(3),
      ),
      Paint()..color = kMuted.withValues(alpha: .4),
    );

    for (final dx in [72.0, 128.0]) {
      final grip = Rect.fromCenter(center: Offset(dx, 112), width: 28, height: 14);
      canvas.drawOval(grip, Paint()..color = kCard);
      canvas.drawOval(
        grip,
        Paint()
          ..color = kGreen.withValues(alpha: .4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _ring(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double width,
    double opacity,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  void _orbitStar(
    Canvas canvas,
    Offset center,
    double radius,
    double periodSeconds,
    Color color,
    double opacity, {
    required bool reverse,
  }) {
    final angle = _cycles(periodSeconds) * math.pi * 2 * (reverse ? -1 : 1);
    final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    _star(canvas, point, 2.2, color.withValues(alpha: opacity));
  }

  void _orbitCircle(
    Canvas canvas,
    Offset center,
    double radius,
    double periodSeconds,
    Color color,
    double opacity,
  ) {
    final angle = -_cycles(periodSeconds) * math.pi * 2;
    final point = center + Offset(math.cos(angle), math.sin(angle) * .3 - 1) * radius;
    canvas.drawCircle(point, 3.5, Paint()..color = color.withValues(alpha: opacity));
  }

  void _orbitStarScaled(Canvas canvas, Offset center, double periodSeconds) {
    final angle = _cycles(periodSeconds) * math.pi * 2;
    final point = center + Offset(math.cos(angle), math.sin(angle) * .55) * 68;
    _star(canvas, point, 1.4, kGreen.withValues(alpha: .5));
  }

  void _sparkle(
    Canvas canvas,
    Offset point,
    double radius,
    double phaseSeconds,
    double periodSeconds,
  ) {
    final t = (_cycles(periodSeconds) + phaseSeconds / periodSeconds) % 1;
    final pulse = .2 + .7 * ((math.sin(t * math.pi * 2) + 1) / 2);
    canvas.drawCircle(
      point,
      radius * (.7 + pulse * .6),
      Paint()..color = kGreen.withValues(alpha: pulse),
    );
  }

  void _star(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final r = i.isEven ? radius : radius * .38;
      final angle = -math.pi / 2 + i * math.pi / 4;
      final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant SceneDiscoverPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
