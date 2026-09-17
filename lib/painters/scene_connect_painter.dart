import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_palette.dart';

const _viewBox = Rect.fromLTWH(-10, -10, 220, 185);
const _center = Offset(100, 80);

class _Satellite {
  const _Satellite(this.point, this.initial, this.label, this.color);
  final Offset point;
  final String initial;
  final String label;
  final Color color;
}

const _satellites = [
  _Satellite(Offset(36, 32), 'A', 'Creator', kTeal),
  _Satellite(Offset(164, 32), 'B', 'Creator', kTeal),
  _Satellite(Offset(30, 128), 'S', 'Streamer', kGreen),
  _Satellite(Offset(170, 128), 'C', 'Creator', kGreen),
];

/// Page 3: the developer at the center of a network of creators and
/// streamers, connected by pulsing dashed lines with traveling signal dots.
class SceneConnectPainter extends CustomPainter {
  const SceneConnectPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    withViewBox(canvas, size, _viewBox, (canvas) {
      final glowRect = Rect.fromCenter(center: _center, width: 164, height: 124);
      canvas.drawOval(
        glowRect,
        Paint()
          ..shader = RadialGradient(
            colors: [kGreen.withValues(alpha: .18), kGreen.withValues(alpha: 0)],
          ).createShader(glowRect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      for (var i = 0; i < _satellites.length; i++) {
        _edge(canvas, i);
      }
      for (var i = 0; i < _satellites.length; i++) {
        _signalDot(canvas, i);
      }

      _devNode(canvas);
      for (var i = 0; i < _satellites.length; i++) {
        _satelliteNode(canvas, i);
      }
    });
  }

  void _edge(Canvas canvas, int i) {
    final delaySeconds = i * .4;
    final t = ((progress * 12 / 2.5) + delaySeconds / 2.5) % 1;
    final opacity = .12 + .43 * ((math.sin(t * math.pi * 2) + 1) / 2);
    drawDashedLine(
      canvas,
      _center,
      _satellites[i].point,
      kGreen.withValues(alpha: opacity),
      1,
      dash: 3,
      gap: 3,
    );
  }

  void _signalDot(Canvas canvas, int i) {
    final periodSeconds = 2.0 + i * .2;
    final beginSeconds = i * .5;
    final path = Path()
      ..moveTo(_center.dx, _center.dy)
      ..lineTo(_satellites[i].point.dx, _satellites[i].point.dy);
    final metric = path.computeMetrics().first;
    final t = ((progress * 12 / periodSeconds) + beginSeconds / periodSeconds) % 1;
    final tangent = metric.getTangentForOffset(t * metric.length);
    if (tangent == null) return;
    canvas.drawCircle(
      tangent.position,
      2.5,
      Paint()..color = (i.isEven ? kTeal : kGreen).withValues(alpha: .9),
    );
  }

  void _devNode(Canvas canvas) {
    canvas.drawCircle(_center, 22, Paint()..color = kCard);
    canvas.drawCircle(
      _center,
      22,
      Paint()
        ..color = kGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final spinAngle = progress * 12 / 12 * math.pi * 2; // spinSlow: 12s/turn
    canvas.save();
    canvas.translate(_center.dx, _center.dy);
    canvas.rotate(spinAngle);
    canvas.translate(-_center.dx, -_center.dy);
    _dashedCircle(canvas, _center, 29, kGreen.withValues(alpha: .25), .8);
    canvas.restore();

    drawLabel(
      canvas,
      'Dev',
      _center,
      color: kInk,
      fontSize: 8,
      fontWeight: FontWeight.w600,
    );
  }

  void _satelliteNode(Canvas canvas, int i) {
    final sat = _satellites[i];
    final period = 4 + i * .1;
    final t = (progress * 12 / period + i * .12) % 1;
    final floatY = math.sin(t * math.pi * 2) * 3.5;
    final point = sat.point + Offset(0, floatY);

    canvas.drawCircle(point, 18, Paint()..color = kCard);
    canvas.drawCircle(
      point,
      18,
      Paint()
        ..color = sat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    drawLabel(
      canvas,
      sat.initial,
      point,
      color: sat.color,
      fontSize: 7.5,
      fontWeight: FontWeight.w800,
    );
    final labelBelow = sat.point.dy > _center.dy;
    drawLabel(
      canvas,
      sat.label,
      point + Offset(0, labelBelow ? 26 : -26),
      color: kInk.withValues(alpha: .9),
      fontSize: 6.5,
      fontWeight: FontWeight.w500,
    );
  }

  void _dashedCircle(Canvas canvas, Offset center, double radius, Color color, double width) {
    const dashAngle = .1;
    const gapAngle = .18;
    for (double a = 0; a < math.pi * 2; a += dashAngle + gapAngle) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        a,
        dashAngle,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SceneConnectPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
