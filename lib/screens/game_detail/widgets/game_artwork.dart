import 'package:flutter/material.dart';
import '../../../core/models/game_preview.dart';

class GameArtwork extends StatelessWidget {
  const GameArtwork({
    super.key,
    required this.game,
    required this.width,
    required this.height,
    this.radius = 16,
  });
  final GamePreview game;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: game.colors,
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -28,
          top: -22,
          child: Icon(
            game.icon,
            size: height * .72,
            color: Colors.white.withValues(alpha: .12),
          ),
        ),
        Center(
          child: Icon(
            game.icon,
            size: height * .34,
            color: Colors.white.withValues(alpha: .82),
          ),
        ),
      ],
    ),
  );
}
