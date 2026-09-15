import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../service/auth_service.dart';
import '../authentication_screens/login_selection_screen.dart';

class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('My Profile', style: AppTextStyles.pageTitle),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.primaryContainer,
          child: Icon(Icons.person_rounded, color: AppColors.primary, size: 44),
        ),
        const SizedBox(height: 14),
        const Text(
          'Faisal AlAnazi',
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 4),
        const Text(
          'Game Developer',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(
              child: _ProfileStat(value: '3', label: 'Games'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ProfileStat(value: '1', label: 'Upcoming Event'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _ProfileStat(value: '12', label: 'Saved Creators'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _ProfileAction(icon: Icons.edit_outlined, label: 'Edit Profile'),
        _ProfileAction(icon: Icons.sports_esports_outlined, label: 'My Games'),
        _ProfileAction(icon: Icons.event_outlined, label: 'My Events'),
        _ProfileAction(
          icon: Icons.favorite_border_rounded,
          label: 'Saved Creators',
        ),
        _ProfileAction(
          icon: Icons.logout_rounded,
          label: 'Sign out',
          onTap: () => _signOut(context),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

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
          Text(value, style: AppTextStyles.sectionTitle),
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

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap ?? () {},
    );
  }
}
