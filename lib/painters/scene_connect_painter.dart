import 'dart:math' as math;

import 'package:flutter/material.dart';

const _green = Color(0xFF1ED87A);
const _teal = Color(0xFF0ECBAD);
const _ink = Color(0xFFF0F5F3);
const _card = Color(0xFF0D1F18);

class SceneConnectPainter extends CustomPainter {
  const SceneConnectPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = const Offset(100, 72);
    final glowRect = Rect.fromCenter(
      center: const Offset(100, 82),
      width: 144,
      height: 108,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [_green.withValues(alpha: .18), _green.withValues(alpha: 0)],
        ).createShader(glowRect),
    );

    const satellites = <(Offset, String)>[
      (Offset(52, 46), 'Creator A'),
      (Offset(150, 46), 'Creator B'),
      (Offset(40, 104), 'Streamer'),
      (Offset(158, 104), 'Creator C'),
    ];
    for (var i = 0; i < satellites.length; i++) {
      final point = satellites[i].$1;
      final pulse =
          .12 + .43 * ((math.sin(progress * math.pi * 2 + i * .55) + 1) / 2);
      _dashedLine(
        canvas,
        center,
        point,
        _green.withValues(alpha: pulse),
        3,
        3,
        1,
      );
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(point.dx, point.dy);
      final metric = path.computeMetrics().first;
      final distance =
          ((progress * (1.05 + i * .12) + i * .17) % 1) * metric.length;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          2.5,
          Paint()..color = _teal.withValues(alpha: .9),
        );
      }
    }

    final ring = Rect.fromCircle(center: center, radius: 22);
    for (
      double a = progress * math.pi * 2;
      a < progress * math.pi * 2 + math.pi * 2;
      a += .28
    ) {
      canvas.drawArc(
        ring,
        a,
        .12,
        false,
        Paint()
          ..color = _green.withValues(alpha: .25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
    }
    _node(canvas, center, 18, _green, 'Dev', 6.5, 2);
    for (var i = 0; i < satellites.length; i++) {
      final floatY =
          math.sin(progress * math.pi * 2 * (1 + i * .09) + i * .7) * 3.5;
      _node(
        canvas,
        satellites[i].$1 + Offset(0, floatY),
        11,
        _teal,
        satellites[i].$2,
        5.5,
        1.2,
      );
    }
  }

  void _node(
    Canvas canvas,
    Offset center,
    double radius,
    Color stroke,
    String text,
    double fontSize,
    double width,
  ) {
    canvas.drawCircle(center, radius, Paint()..color = _card);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
    final label = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontFamily: 'Sora', fontSize: fontSize, color: _ink),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, center - Offset(label.width / 2, label.height / 2));
  }

  void _dashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Color color,
    double dash,
    double gap,
    double width,
  ) {
    final length = (b - a).distance;
    final direction = (b - a) / length;
    for (double d = 0; d < length; d += dash + gap) {
      canvas.drawLine(
        a + direction * d,
        a + direction * math.min(d + dash, length),
        Paint()
          ..color = color
          ..strokeWidth = width,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SceneConnectPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
