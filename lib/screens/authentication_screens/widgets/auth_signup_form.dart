import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';

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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primaryContainer,
          child: Icon(widget.icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 24),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: AppTextStyles.pageTitle,
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 36),
        if (widget.extraFieldController != null) ...[
          TextField(
            controller: widget.extraFieldController,
            decoration: InputDecoration(
              labelText: widget.extraFieldLabel,
              hintText: widget.extraFieldHint,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.error),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign up'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onHaveAccount,
          child: const Text('Already have an account? Log in'),
        ),
      ],
    );
  }
}
