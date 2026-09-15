import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/game.dart';
import 'add_event_screen.dart';
import 'add_game_screen.dart';

class DeveloperGameDetailScreen extends StatefulWidget {
  const DeveloperGameDetailScreen({super.key, required this.game});

  final Game game;

  @override
  State<DeveloperGameDetailScreen> createState() =>
      _DeveloperGameDetailScreenState();
}

class _DeveloperGameDetailScreenState extends State<DeveloperGameDetailScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final pages = [
      _AboutTab(game: game, onEditGame: _openEditGame),
      _EventsTab(game: game, onAddEvent: _openAddEvent),
      const _LinksTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          (game.coverImage == null || game.coverImage!.isEmpty)
              ? const _FallbackHeader()
              : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    game.coverImage!,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _FallbackHeader(),
                  ),
                ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text(game.name, style: AppTextStyles.pageTitle)),
              Chip(
                label: Text(game.displayStatus),
                backgroundColor: AppColors.primary,
                labelStyle: AppTextStyles.label.copyWith(color: Colors.black),
              ),
            ],
          ),
          Text(
            'by ${game.developer ?? 'Unknown developer'}',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 12),
          if (game.genres.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                for (final genre in game.genres) Chip(label: Text(genre)),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            game.description ?? 'No description provided.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Play on Steam'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openEditGame,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Game'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('About')),
              ButtonSegment(value: 1, label: Text('Events')),
              ButtonSegment(value: 2, label: Text('Links')),
            ],
            selected: {selectedTab},
            onSelectionChanged: (value) =>
                setState(() => selectedTab = value.first),
          ),
          const SizedBox(height: 18),
          pages[selectedTab],
        ],
      ),
    );
  }

  Future<void> _openAddEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEventScreen()),
    );
  }

  Future<void> _openEditGame() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddGameScreen()),
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.game, required this.onEditGame});

  final Game game;
  final VoidCallback onEditGame;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailRow(
          label: 'Genre',
          value: game.genres.isNotEmpty ? game.genres.join(', ') : 'Not set',
        ),
        _DetailRow(label: 'Status', value: game.displayStatus),
        _DetailRow(
          label: 'Release Date',
          value: game.releaseDate ?? 'Coming soon',
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onEditGame,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Game Details'),
        ),
      ],
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.game, required this.onAddEvent});

  final Game game;
  final VoidCallback onAddEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAddEvent,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Event'),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${game.name} Playtest', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Chip(
                label: const Text('Playtest'),
                backgroundColor: AppColors.primaryContainer,
                labelStyle: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sep 20, 2024 • 4:00 PM - 8:00 PM',
                style: AppTextStyles.bodyMuted,
              ),
              const Text(
                'Riyadh, Saudi Arabia',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 10),
              const Text(
                'Be one of the first to experience the game and share feedback.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onAddEvent,
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('View'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FallbackHeader extends StatelessWidget {
  const _FallbackHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD47A3B), Color(0xFF211117)],
        ),
      ),
      child: const Icon(
        Icons.sports_esports_rounded,
        color: Colors.white70,
        size: 88,
      ),
    );
  }
}

class _LinksTab extends StatelessWidget {
  const _LinksTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DetailRow(label: 'Steam', value: 'store.steampowered.com'),
        _DetailRow(label: 'Website', value: 'desertpixel.studio'),
        _DetailRow(label: 'Press Kit', value: 'Available'),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
