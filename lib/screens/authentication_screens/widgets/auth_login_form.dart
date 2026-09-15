import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';
import 'auth_background.dart';

class AuthLoginForm extends StatefulWidget {
  const AuthLoginForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onLogin,
    required this.onCreateAccount,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Future<String?> Function(String email, String password) onLogin;
  final VoidCallback onCreateAccount;

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Enter your password.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    String? error;
    try {
      error = await widget.onLogin(email, password);
    } catch (e, st) {
      debugPrint('Login failed: $e\n$st');
      error = 'Something went wrong: $e';
    } finally {
      if (mounted) setState(() => _submitting = false);
    }

    if (!mounted) return;
    setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    return AuthDecoratedBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primaryContainer.withValues(
                alpha: 0.72,
              ),
              child: Icon(widget.icon, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 22),
            const Text(
              'INDIVERSE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Michroma',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.pageTitle.copyWith(fontSize: 30),
            ),
            const SizedBox(height: 10),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 32),
            AuthGlassPanel(
              child: Column(
                children: [
                  AuthSegmentedControl(
                    activeLabel: 'Login',
                    inactiveLabel: 'Register',
                    onInactivePressed: widget.onCreateAccount,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: authFieldDecoration(
                      label: 'Email',
                      hint: 'you@example.com',
                      icon: Icons.mail_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: authFieldDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AuthPrimaryButton(
                    label: 'Log in',
                    loading: _submitting,
                    onPressed: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 22),
                  const AuthOrDivider(),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: widget.onCreateAccount,
                    child: const Text('Create a new account'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
