import 'dart:math' as math;

import 'package:flutter/material.dart';

const _green = Color(0xFF1ED87A);
const _teal = Color(0xFF0ECBAD);
const _silver = Color(0xFFC8D8D4);
const _muted = Color(0xFF6B7F7A);
const _card = Color(0xFF0D1F18);

class SceneDiscoverPainter extends CustomPainter {
  const SceneDiscoverPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .5125);
    _glow(canvas, center, 72, 54, _green, .22);

    final floatY = -3.5 + math.sin(progress * math.pi * 2) * 3.5;
    canvas.save();
    canvas.translate(0, floatY);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 96, height: 56),
      const Radius.circular(28),
    );
    canvas.drawRRect(body, Paint()..color = _card);
    canvas.drawRRect(
      body,
      Paint()
        ..color = _green.withValues(alpha: .7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final dpad = Paint()..color = _green.withValues(alpha: .8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 32, center.dy + 4, 6, 16),
        const Radius.circular(3),
      ),
      dpad,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 37, center.dy + 9, 16, 6),
        const Radius.circular(3),
      ),
      dpad,
    );
    _ring(canvas, center + const Offset(32, 4), 4, _teal, 1.5);
    _ring(canvas, center + const Offset(40, 12), 4, _green, 1.5);
    _ring(canvas, center + const Offset(24, 12), 4, _silver, 1.5);
    _ring(
      canvas,
      center + const Offset(32, 20),
      4,
      _teal.withValues(alpha: .5),
      .8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(0, 8),
          width: 6,
          height: 16,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = _muted.withValues(alpha: .4),
    );
    for (final dx in [-28.0, 28.0]) {
      final grip = Rect.fromCenter(
        center: center + Offset(dx, 30),
        width: 28,
        height: 14,
      );
      canvas.drawOval(grip, Paint()..color = _card);
      canvas.drawOval(
        grip,
        Paint()
          ..color = _green.withValues(alpha: .4)
          ..style = PaintingStyle.stroke,
      );
    }
    canvas.restore();

    _orbitStar(canvas, center, 68, 0, 9, 4, _green, .7);
    _orbitStar(canvas, center, 58, math.pi / 2, -6, 3.5, _teal, .8);
    _orbitStar(canvas, center, 68, math.pi, 11, 3, _green, .5);
    _sparkle(canvas, const Offset(48, 54), 2, 0);
    _sparkle(canvas, const Offset(156, 60), 1.5, .35);
    _sparkle(canvas, const Offset(102, 38), 1.5, .7);
  }

  void _orbitStar(
    Canvas canvas,
    Offset center,
    double radius,
    double start,
    double seconds,
    double size,
    Color color,
    double opacity,
  ) {
    final angle = start + progress * math.pi * 2 * (12 / seconds);
    final point =
        center +
        Offset(math.cos(angle) * radius, math.sin(angle) * radius * .55);
    _star(canvas, point, size, color.withValues(alpha: opacity));
  }

  void _sparkle(Canvas canvas, Offset point, double radius, double phase) {
    final pulse =
        .2 + .7 * ((math.sin((progress + phase) * math.pi * 2) + 1) / 2);
    canvas.drawCircle(
      point,
      radius * (.7 + pulse * .6),
      Paint()..color = _green.withValues(alpha: pulse),
    );
  }

  void _star(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final r = i.isEven ? radius : radius * .38;
      final angle = -math.pi / 2 + i * math.pi / 4;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  void _ring(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double width,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  void _glow(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    Color color,
    double alpha,
  ) {
    final rect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant SceneDiscoverPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
