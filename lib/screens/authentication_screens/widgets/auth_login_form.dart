import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';

class AuthLoginForm extends StatelessWidget {
  const AuthLoginForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onLogin,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primaryContainer,
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 36),
        const TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
        ),
        const SizedBox(height: 14),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Forgot password?'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onLogin,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('Log in'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: () {}, child: const Text('Create a new account')),
      ],
    );
  }
}
