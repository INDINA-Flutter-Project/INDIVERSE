import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import 'add_game_screen.dart';
import 'game_detail_screen.dart';
import 'widgets/developer_game_tile.dart';
import 'widgets/developer_stat_card.dart';

class DeveloperHomeScreen extends StatelessWidget {
  const DeveloperHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        Row(
          children: [
            Image.asset('assets/images/indiverse_icon.png', width: 46),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('INDIVERSE', style: AppTextStyles.sectionTitle),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text('Welcome, Developer', style: AppTextStyles.pageTitle),
        const SizedBox(height: 8),
        const Text(
          "Let's bring your games to players and creators.",
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: DeveloperStatCard(
                label: 'My Games',
                value: '3',
                icon: Icons.sports_esports_rounded,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: DeveloperStatCard(
                label: 'Upcoming Events',
                value: '1',
                icon: Icons.event_available_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(
              child: Text('Your Games', style: AppTextStyles.sectionTitle),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DeveloperGameTile(
          title: 'The Last Sand',
          subtitle: 'Horror • PC',
          status: 'Published',
          accentColor: const Color(0xFFD47A3B),
          icon: Icons.temple_hindu_rounded,
          onTap: () => _openGameDetail(context),
        ),
        const SizedBox(height: 12),
        DeveloperGameTile(
          title: 'Neon Wadi',
          subtitle: 'Action • PC',
          status: 'In Development',
          accentColor: const Color(0xFF5B6BFF),
          icon: Icons.bolt_rounded,
          onTap: () => _openGameDetail(context),
        ),
        const SizedBox(height: 12),
        DeveloperGameTile(
          title: 'Desert Echo',
          subtitle: 'Adventure • PC',
          status: 'Draft',
          accentColor: AppColors.warning,
          icon: Icons.landscape_rounded,
          onTap: () => _openGameDetail(context),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _openAddGame(context),
          icon: const Icon(Icons.add_rounded),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Add New Game'),
          ),
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
