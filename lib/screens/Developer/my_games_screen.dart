import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import 'add_game_screen.dart';
import 'game_detail_screen.dart';
import 'widgets/developer_game_tile.dart';

class MyGamesScreen extends StatelessWidget {
  const MyGamesScreen({super.key});

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
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'all', label: Text('All')),
            ButtonSegment(value: 'published', label: Text('Published')),
            ButtonSegment(value: 'draft', label: Text('Draft')),
          ],
          selected: const {'all'},
          onSelectionChanged: (_) {},
        ),
        const SizedBox(height: 20),
        DeveloperGameTile(
          title: 'The Last Sand',
          subtitle: 'Horror • PC • Demo',
          status: 'Published',
          accentColor: const Color(0xFFD47A3B),
          icon: Icons.temple_hindu_rounded,
          showMenu: true,
          onTap: () => _openGameDetail(context),
        ),
        const SizedBox(height: 12),
        DeveloperGameTile(
          title: 'Neon Wadi',
          subtitle: 'Action • PC',
          status: 'In Development',
          accentColor: const Color(0xFF5B6BFF),
          icon: Icons.bolt_rounded,
          showMenu: true,
          onTap: () => _openGameDetail(context),
        ),
        const SizedBox(height: 12),
        DeveloperGameTile(
          title: 'Desert Echo',
          subtitle: 'Adventure • PC',
          status: 'Draft',
          accentColor: AppColors.warning,
          icon: Icons.landscape_rounded,
          showMenu: true,
          onTap: () => _openGameDetail(context),
        ),
      ],
    );
  }

  void _openAddGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddGameScreen()),
    );
  }

  void _openGameDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeveloperGameDetailScreen()),
    );
  }
}
