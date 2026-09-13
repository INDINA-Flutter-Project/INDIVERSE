import 'package:flutter/material.dart';

import 'core/models/game_preview.dart';

/// Clearly fictional fixtures used while the frontend is backend-independent.
const sampleGames = <GamePreview>[
  GamePreview(
    title: 'Sands of Diriyah',
    studio: 'Palm Forge Studio',
    description:
        'Explore a forgotten city, uncover its stories, and master fast-paced combat in a world inspired by Arabia.',
    genres: ['Adventure', 'Story Rich'],
    platforms: ['PC', 'PlayStation'],
    status: 'Coming soon',
    colors: [Color(0xFFB96832), Color(0xFF3B1938)],
    icon: Icons.temple_buddhist_rounded,
  ),
  GamePreview(
    title: 'Neon Falcons',
    studio: 'Riyadh Byte',
    description:
        'Race above a future Riyadh in a precision arcade challenge built for quick runs and fearless pilots.',
    genres: ['Action', 'Indie'],
    platforms: ['PC', 'Xbox'],
    status: 'Demo available',
    colors: [Color(0xFF2856A8), Color(0xFF8D2CA1)],
    icon: Icons.rocket_launch_rounded,
  ),
  GamePreview(
    title: 'The Last Date Farm',
    studio: 'Nakhla Games',
    description:
        'Restore your family farm, meet the neighboring community, and turn a quiet oasis into a thriving home.',
    genres: ['Simulation', 'Cozy'],
    platforms: ['PC', 'Nintendo'],
    status: 'Released',
    colors: [Color(0xFF2F7955), Color(0xFFC49540)],
    icon: Icons.park_rounded,
  ),
];
