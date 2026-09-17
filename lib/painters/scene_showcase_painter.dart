import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_palette.dart';

const _viewBox = Rect.fromLTWH(0, 0, 200, 160);
const _nodeX = [46.0, 84.0, 122.0, 158.0];
const _labels = ['Concept', 'Alpha', 'Beta', 'Launch'];

/// Page 2: a milestone timeline — two completed, one in progress, one future.
class SceneShowcasePainter extends CustomPainter {
  const SceneShowcasePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    withViewBox(canvas, size, _viewBox, (canvas) {
      const glowRect = Rect.fromLTWH(28, 28, 144, 108);
      canvas.drawOval(
        glowRect,
        Paint()
          ..shader = RadialGradient(
            colors: [kTeal.withValues(alpha: .18), kTeal.withValues(alpha: 0)],
          ).createShader(glowRect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      drawDashedLine(
        canvas,
        const Offset(36, 82),
        const Offset(164, 82),
        kGreen.withValues(alpha: .35),
        1.5,
        dash: 4,
        gap: 3,
      );

      for (var i = 0; i < _nodeX.length; i++) {
        _milestone(canvas, i);
      }

      _pulse(canvas, const Offset(60, 100), 1.5, kTeal, 0, 2.2);
      _pulse(canvas, const Offset(98, 108), 2, kGreen, .35, 2.2);
      _pulse(canvas, const Offset(135, 102), 1.5, kTeal, .8, 2.2);
    });
  }

  void _milestone(Canvas canvas, int i) {
    final done = i < 2;
    final future = i == 3;
    final x = _nodeX[i];
    final period = 4 + i * .2;
    final t = (progress * 12 / period + i * .1) % 1;
    final floatY = math.sin(t * math.pi * 2) * 2.5;

    final tone = done ? kGreen : kMuted;
    final strokeOpacity = done ? .7 : (future ? .25 : .4);

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, 64 + floatY), width: 36, height: 20),
      const Radius.circular(5),
    );
    canvas.drawRRect(cardRect, Paint()..color = kCard);
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = tone.withValues(alpha: strokeOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );
    drawLabel(
      canvas,
      _labels[i],
      Offset(x, 64 + floatY),
      color: tone.withValues(alpha: done ? 1 : .8),
      fontSize: 7,
    );
    canvas.drawLine(
      Offset(x, 73 + floatY),
      Offset(x, 74 + floatY),
      Paint()..color = tone.withValues(alpha: strokeOpacity),
    );

    final node = Offset(x, 82 + floatY);
    canvas.drawCircle(node, 9, Paint()..color = done ? kGreen : kCard);
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
          ..color = kMuted.withValues(alpha: future ? .3 : .5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _pulse(
    Canvas canvas,
    Offset point,
    double radius,
    Color color,
    double phaseSeconds,
    double periodSeconds,
  ) {
    final t = (progress * 12 / periodSeconds + phaseSeconds / periodSeconds) % 1;
    final value = .2 + .7 * ((math.sin(t * math.pi * 2) + 1) / 2);
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
