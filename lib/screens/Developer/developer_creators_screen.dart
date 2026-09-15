import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/game.dart';
import 'creator_profile_screen.dart';

class DeveloperCreatorsScreen extends StatefulWidget {
  const DeveloperCreatorsScreen({super.key, required this.games});

  final List<Game> games;

  @override
  State<DeveloperCreatorsScreen> createState() =>
      _DeveloperCreatorsScreenState();
}

class _DeveloperCreatorsScreenState extends State<DeveloperCreatorsScreen> {
  Game? selectedGame;

  @override
  Widget build(BuildContext context) {
    final chosenGame =
        selectedGame ?? (widget.games.isNotEmpty ? widget.games.first : null);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        const Text('Creators', style: AppTextStyles.pageTitle),
        const SizedBox(height: 8),
        const Text(
          'Choose a game and see creators who match its audience.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 20),
        _GameSelector(
          games: widget.games,
          selectedGame: chosenGame,
          onChanged: (game) => setState(() => selectedGame = game),
        ),
        const SizedBox(height: 24),
        const Text('Best Matches', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        _CreatorMatchCard(
          name: 'BanderitaX',
          focus: 'Horror • Indie • PC',
          matches: '3 Matches',
          icon: Icons.person_rounded,
          onTap: () => _openCreatorProfile(context),
        ),
        const SizedBox(height: 12),
        _CreatorMatchCard(
          name: 'AboFlah',
          focus: 'Challenges • Horror',
          matches: '2 Matches',
          icon: Icons.person_rounded,
          onTap: () => _openCreatorProfile(context),
        ),
        const SizedBox(height: 12),
        _CreatorMatchCard(
          name: 'Rima',
          focus: 'Indie • Story Games',
          matches: '2 Matches',
          icon: Icons.person_rounded,
          onTap: () => _openCreatorProfile(context),
        ),
      ],
    );
  }

  void _openCreatorProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatorProfileScreen()),
    );
  }
}

class _GameSelector extends StatelessWidget {
  const _GameSelector({
    required this.games,
    required this.selectedGame,
    required this.onChanged,
  });

  final List<Game> games;
  final Game? selectedGame;
  final ValueChanged<Game> onChanged;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('Add a game first', style: AppTextStyles.bodyMuted),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showGamePicker(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected game', style: AppTextStyles.bodyMuted),
                  const SizedBox(height: 2),
                  Text(
                    selectedGame?.name ?? 'Select a game',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Future<void> _showGamePicker(BuildContext context) async {
    final game = await showModalBottomSheet<Game>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose a game', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 12),
              for (final game in games)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(game.name, style: AppTextStyles.body),
                  subtitle: Text(
                    game.genres.take(2).join(' • '),
                    style: AppTextStyles.bodyMuted,
                  ),
                  trailing: selectedGame?.id == game.id
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, game),
                ),
            ],
          ),
        ),
      ),
    );
    if (game != null) onChanged(game);
  }
}

class _CreatorMatchCard extends StatelessWidget {
  const _CreatorMatchCard({
    required this.name,
    required this.focus,
    required this.matches,
    required this.icon,
    required this.onTap,
  });

  final String name;
  final String focus;
  final String matches;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(focus, style: AppTextStyles.bodyMuted),
                ],
              ),
            ),
            Chip(
              label: Text(matches),
              backgroundColor: AppColors.primary,
              labelStyle: AppTextStyles.label.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
