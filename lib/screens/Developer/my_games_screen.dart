import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/game.dart';
import 'add_game_screen.dart';
import 'game_detail_screen.dart';
import 'widgets/developer_game_tile.dart';

const _tileAccents = [
  (Color(0xFFD47A3B), Icons.temple_hindu_rounded),
  (Color(0xFF5B6BFF), Icons.bolt_rounded),
  (AppColors.warning, Icons.landscape_rounded),
];

class MyGamesScreen extends StatelessWidget {
  const MyGamesScreen({
    super.key,
    required this.games,
    required this.onGamesChanged,
  });

  final List<Game> games;
  final Future<void> Function() onGamesChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('My Games', style: AppTextStyles.pageTitle),
            ),
            FilledButton.icon(
              onPressed: () => _openAddGame(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Game'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (games.isEmpty)
          _EmptyGamesNotice(onAddGame: () => _openAddGame(context))
        else
          for (var i = 0; i < games.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _GameTileFor(
              game: games[i],
              index: i,
              onTap: () => _openGameDetail(context, games[i]),
            ),
          ],
      ],
    );
  }

  Future<void> _openAddGame(BuildContext context) async {
    final published = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddGameScreen()),
    );
    if (published == true) await onGamesChanged();
  }

  Future<void> _openGameDetail(BuildContext context, Game game) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DeveloperGameDetailScreen(game: game)),
    );
    if (changed == true) await onGamesChanged();
  }
}

class _GameTileFor extends StatelessWidget {
  const _GameTileFor({
    required this.game,
    required this.index,
    required this.onTap,
  });

  final Game game;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (accentColor, icon) = _tileAccents[index % _tileAccents.length];
    final subtitle = game.genres.isNotEmpty
        ? game.genres.join(' • ')
        : (game.shortDescription ?? game.description ?? '');

    return DeveloperGameTile(
      title: game.name,
      subtitle: subtitle,
      status: game.displayStatus,
      accentColor: accentColor,
      icon: icon,
      imageUrl: game.coverImage,
      showMenu: true,
      onTap: onTap,
    );
  }
}

class _EmptyGamesNotice extends StatelessWidget {
  const _EmptyGamesNotice({required this.onAddGame});

  final VoidCallback onAddGame;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.sports_esports_outlined, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text(
            "You haven't published any games yet.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onAddGame,
            child: const Text('Add your first game'),
          ),
        ],
      ),
    );
  }
}
