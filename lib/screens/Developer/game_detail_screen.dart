import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import 'add_event_screen.dart';
import 'add_game_screen.dart';

class DeveloperGameDetailScreen extends StatefulWidget {
  const DeveloperGameDetailScreen({super.key});

  @override
  State<DeveloperGameDetailScreen> createState() => _DeveloperGameDetailScreenState();
}

class _DeveloperGameDetailScreenState extends State<DeveloperGameDetailScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _AboutTab(onEditGame: _openEditGame),
      _EventsTab(onAddEvent: _openAddEvent),
      const _LinksTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Last Sand'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Container(
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
              Icons.temple_hindu_rounded,
              color: Colors.white70,
              size: 88,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text('The Last Sand', style: AppTextStyles.pageTitle),
              ),
              Chip(
                label: const Text('Published'),
                backgroundColor: AppColors.primary,
                labelStyle: AppTextStyles.label.copyWith(color: Colors.black),
              ),
            ],
          ),
          const Text('by Desert Pixel Studio', style: AppTextStyles.bodyMuted),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('Horror')),
              Chip(label: Text('PC')),
              Chip(label: Text('Demo')),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'A first-person psychological horror game set in an abandoned Saudi village, where ancient stories come to life.',
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
            onSelectionChanged: (value) => setState(() => selectedTab = value.first),
          ),
          const SizedBox(height: 18),
          pages[selectedTab],
        ],
      ),
    );
  }

  void _openAddEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEventScreen()),
    );
  }

  void _openEditGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddGameScreen()),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.onEditGame});

  final VoidCallback onEditGame;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DetailRow(label: 'Genre', value: 'Horror'),
        const _DetailRow(label: 'Platform', value: 'PC'),
        const _DetailRow(label: 'Release Date', value: 'Coming soon'),
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
  const _EventsTab({required this.onAddEvent});

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
              const Text('The Last Sand Playtest', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Chip(
                label: const Text('Playtest'),
                backgroundColor: AppColors.primaryContainer,
                labelStyle: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text('Sep 20, 2024 • 4:00 PM - 8:00 PM', style: AppTextStyles.bodyMuted),
              const Text('Riyadh, Saudi Arabia', style: AppTextStyles.bodyMuted),
              const SizedBox(height: 10),
              const Text(
                'Be one of the first to experience the game and share feedback.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: onAddEvent, child: const Text('Edit'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () {}, child: const Text('View'))),
                ],
              ),
            ],
          ),
        ),
      ],
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
