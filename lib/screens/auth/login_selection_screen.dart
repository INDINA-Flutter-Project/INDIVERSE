import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import 'developer_login/developer_login_screen.dart';
import 'user_login/user_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Icon(
              Icons.gamepad_rounded,
              size: 72,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'INDIVERSE',
              textAlign: TextAlign.center,
              style: AppTextStyles.pageTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Saudi indie games, all in one place.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserLoginScreen()),
              ),
              icon: const Icon(Icons.person_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text('Continue as User'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeveloperLoginScreen()),
              ),
              icon: const Icon(Icons.code_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text('Continue as Developer'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
