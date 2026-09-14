import 'package:flutter/material.dart';

/// Temporary UI model for the read-only player vertical slice.
///
/// It can later be mapped from the backend Game entity without coupling UI
/// widgets to Supabase response shapes.
class GamePreview {
  const GamePreview({
    required this.title,
    required this.studio,
    required this.description,
    required this.genres,
    required this.platforms,
    required this.status,
    required this.colors,
    required this.icon,
  });

  final String title;
  final String studio;
  final String description;
  final List<String> genres;
  final List<String> platforms;
  final String status;
  final List<Color> colors;
  final IconData icon;
}
