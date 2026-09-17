import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared color vocabulary for the splash and onboarding flow, matching the
/// branded illustrations 1:1. Distinct from [AppColors] on purpose — these
/// scenes are a one-off first-run moment, not the app's steady-state theme.
const kGreen = Color(0xFF1ED87A);
const kTeal = Color(0xFF0ECBAD);
const kSilver = Color(0xFFC8D8D4);
const kInk = Color(0xFFF0F5F3);
const kMuted = Color(0xFF6B7F7A);
const kBg = Color(0xFF000000);
const kCard = Color(0xFF0D1F18);

/// Paints canvas content authored against an SVG `viewBox`, fitting it into
/// [size] the same way `<svg width height style="overflow:visible">` would:
/// uniform scale-to-fit, centered, with drawing continuing past the box
/// permitted (callers just don't clip).
void withViewBox(
  Canvas canvas,
  Size size,
  Rect viewBox,
  void Function(Canvas canvas) draw,
) {
  final scale = math.min(size.width / viewBox.width, size.height / viewBox.height);
  canvas.save();
  canvas.translate(
    (size.width - viewBox.width * scale) / 2 - viewBox.left * scale,
    (size.height - viewBox.height * scale) / 2 - viewBox.top * scale,
  );
  canvas.scale(scale);
  draw(canvas);
  canvas.restore();
}

void drawLabel(
  Canvas canvas,
  String text,
  Offset center, {
  required Color color,
  required double fontSize,
  FontWeight fontWeight = FontWeight.w500,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
}

void drawDashedLine(
  Canvas canvas,
  Offset a,
  Offset b,
  Color color,
  double width, {
  double dash = 3,
  double gap = 3,
}) {
  final length = (b - a).distance;
  if (length == 0) return;
  final direction = (b - a) / length;
  for (double d = 0; d < length; d += dash + gap) {
    canvas.drawLine(
      a + direction * d,
      a + direction * (d + dash).clamp(0, length),
      Paint()
        ..color = color
        ..strokeWidth = width,
    );
  }
}
