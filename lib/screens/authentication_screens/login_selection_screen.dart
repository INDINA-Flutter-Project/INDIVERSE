import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
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
                    Image.asset(
                      'assets/images/indiverse_wordmark.png',
                      width: 160,
                    ),
                    const SizedBox(height: 22),
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
                    icon: Icons.person_rounded,
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
                    icon: Icons.code_rounded,
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
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.background : AppColors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? null : Colors.white.withValues(alpha: 0.055),
        gradient: filled
            ? const LinearGradient(
                colors: [Color(0xFF37F2A0), Color(0xFF03C878)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: filled
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foreground, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
