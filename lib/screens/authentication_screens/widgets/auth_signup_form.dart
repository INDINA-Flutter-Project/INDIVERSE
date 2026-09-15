import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';
import 'auth_background.dart';

class AuthSignupForm extends StatefulWidget {
  const AuthSignupForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onSignup,
    required this.onHaveAccount,
    this.extraFieldController,
    this.extraFieldLabel,
    this.extraFieldHint,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Future<String?> Function(String email, String password) onSignup;
  final VoidCallback onHaveAccount;
  final TextEditingController? extraFieldController;
  final String? extraFieldLabel;
  final String? extraFieldHint;

  @override
  State<AuthSignupForm> createState() => _AuthSignupFormState();
}

class _AuthSignupFormState extends State<AuthSignupForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    String? error;
    try {
      error = await widget.onSignup(email, password);
    } catch (e, st) {
      debugPrint('Signup failed: $e\n$st');
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
                    activeLabel: 'Register',
                    inactiveLabel: 'Login',
                    onInactivePressed: widget.onHaveAccount,
                  ),
                  const SizedBox(height: 20),
                  if (widget.extraFieldController != null) ...[
                    TextField(
                      controller: widget.extraFieldController,
                      decoration: authFieldDecoration(
                        label: widget.extraFieldLabel ?? 'Name',
                        hint: widget.extraFieldHint,
                        icon: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
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
                  const SizedBox(height: 14),
                  TextField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: authFieldDecoration(
                      label: 'Confirm Password',
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
                  const SizedBox(height: 22),
                  AuthPrimaryButton(
                    label: 'Sign up',
                    loading: _submitting,
                    onPressed: _submitting ? null : _submit,
                  ),
                  const SizedBox(height: 22),
                  const AuthOrDivider(),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: widget.onHaveAccount,
                    child: const Text('Already have an account? Log in'),
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
