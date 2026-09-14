import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';

class CreatorProfileScreen extends StatelessWidget {
  const CreatorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF263934), AppColors.surface],
              ),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.person_rounded, color: AppColors.primary, size: 50),
                ),
                SizedBox(height: 12),
                Text('BanderitaX', style: AppTextStyles.sectionTitle),
                Text('Saudi Gaming Content Creator', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: _CreatorStat(value: '10.2M', label: 'Subscribers')),
              SizedBox(width: 10),
              Expanded(child: _CreatorStat(value: '1.5M', label: 'Followers')),
              SizedBox(width: 10),
              Expanded(child: _CreatorStat(value: 'Horror', label: 'Main Focus')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('About', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          const Text(
            'Variety gaming content with a focus on story games, horror, and indie titles.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 20),
          const Text('Content Focus', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('Horror')),
              Chip(label: Text('Indie')),
              Chip(label: Text('Story Games')),
              Chip(label: Text('PC')),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Visit YouTube Channel'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorStat extends StatelessWidget {
  const _CreatorStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
