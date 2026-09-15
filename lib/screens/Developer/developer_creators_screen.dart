import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import 'creator_profile_screen.dart';

class DeveloperCreatorsScreen extends StatelessWidget {
  const DeveloperCreatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        const _GameSelector(),
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
  const _GameSelector();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text('Select a game', style: AppTextStyles.body)),
            Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
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
