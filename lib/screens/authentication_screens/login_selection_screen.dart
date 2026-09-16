import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/widget/glass_action.dart';
import 'developer_login/developer_login_screen.dart';
import 'user_login/user_login_screen.dart';
import 'widgets/auth_background.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AuthDecoratedBackground(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'INDIVERSE',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Saudi indie games, all in one place.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
            ),
            AuthGlassPanel(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RoleButton(
                    label: 'Continue as User',
                    icon: const Icon(Icons.person_rounded),
                    filled: true,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserLoginScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RoleButton(
                    label: 'Continue as Developer',
                    icon: const Icon(Icons.code_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeveloperLoginScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    ),
  );
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.filled = false,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (!filled) {
      return GlassAction(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: const IconThemeData(color: AppColors.primary, size: 22),
              child: icon,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.interface.copyWith(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF06170F),
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: const IconThemeData(color: Color(0xFF06170F), size: 22),
              child: icon,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.interface.copyWith(
                color: const Color(0xFF06170F),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
