import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/widget/confirm_dialog.dart';
import '../../service/auth_service.dart';
import '../authentication_screens/login_selection_screen.dart';

class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmLabel: 'Confirm',
    );
    if (!confirmed) return;
    // Reset the onboarding flag so a fresh cold launch after this sign-out
    // shows onboarding again, as if the app were new. Within this same
    // session, though, sign-out drops straight to role selection below.
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('onboarding_seen_v2', false);
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final developerName =
        AuthService().currentDeveloperName?.trim().isNotEmpty == true
        ? AuthService().currentDeveloperName!.trim()
        : 'Game Developer';

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        const Text('My Profile', style: AppTextStyles.pageTitle),
        const SizedBox(height: 22),
        const CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.primaryContainer,
          child: Icon(Icons.person_rounded, color: AppColors.primary, size: 44),
        ),
        const SizedBox(height: 14),
        Text(
          developerName,
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
