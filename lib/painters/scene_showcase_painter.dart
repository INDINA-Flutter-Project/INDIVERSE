import 'dart:math' as math;

import 'package:flutter/material.dart';

const _green = Color(0xFF1ED87A);
const _teal = Color(0xFF0ECBAD);
const _muted = Color(0xFF6B7F7A);
const _card = Color(0xFF0D1F18);

class SceneShowcasePainter extends CustomPainter {
  const SceneShowcasePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .5125);
    final glowRect = Rect.fromCenter(center: center, width: 144, height: 108);
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [_teal.withValues(alpha: .18), _teal.withValues(alpha: 0)],
        ).createShader(glowRect),
    );
    _dashedLine(
      canvas,
      const Offset(36, 82),
      const Offset(164, 82),
      _green.withValues(alpha: .35),
      4,
      3,
      1.5,
    );

    const nodes = [46.0, 84.0, 122.0, 158.0];
    const labels = ['Concept', 'Alpha', 'Beta', 'Launch'];
    for (var i = 0; i < nodes.length; i++) {
      final done = i < 2;
      final floatY =
          math.sin(progress * math.pi * 2 * (1 + i * .08) + i * .65) * 3.5;
      final node = Offset(nodes[i], 82 + floatY);
      final cardRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(nodes[i], 64 + floatY),
          width: 36,
          height: 20,
        ),
        const Radius.circular(5),
      );
      final tone = done ? _green : _muted;
      final opacity = done ? .7 : (i == 2 ? .4 : .25);
      canvas.drawRRect(cardRect, Paint()..color = _card);
      canvas.drawRRect(
        cardRect,
        Paint()
          ..color = tone.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
      _label(
        canvas,
        labels[i],
        Offset(nodes[i], 64 + floatY),
        tone.withValues(alpha: done ? 1 : .7),
      );
      canvas.drawLine(
        Offset(nodes[i], 73 + floatY),
        Offset(nodes[i], 74 + floatY),
        Paint()..color = tone.withValues(alpha: .5),
      );
      canvas.drawCircle(node, 9, Paint()..color = done ? _green : _card);
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
      } else {
        canvas.drawCircle(
          node,
          9,
          Paint()
            ..color = _muted.withValues(alpha: i == 2 ? .5 : .3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
    _pulse(canvas, const Offset(60, 100), 1.5, _teal, 0);
    _pulse(canvas, const Offset(98, 108), 2, _green, .35);
    _pulse(canvas, const Offset(135, 102), 1.5, _teal, .7);
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

  void _label(Canvas canvas, String text, Offset center, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontFamily: 'Sora', fontSize: 7, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _pulse(
    Canvas canvas,
    Offset point,
    double radius,
    Color color,
    double phase,
  ) {
    final value =
        .2 + .7 * ((math.sin((progress + phase) * math.pi * 2) + 1) / 2);
    canvas.drawCircle(
      point,
      radius * (.7 + value * .6),
      Paint()..color = color.withValues(alpha: value),
    );
  }

  @override
  bool shouldRepaint(covariant SceneShowcasePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
