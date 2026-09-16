import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/text_styles.dart';
import 'auth_background.dart';

class AuthLoginForm extends StatefulWidget {
  const AuthLoginForm({
    super.key,
    required this.loginTitle,
    required this.signupTitle,
    required this.subtitle,
    required this.onLogin,
    required this.onSignup,
    required this.nameLabel,
    required this.nameHint,
  });

  final String loginTitle;
  final String signupTitle;
  final String subtitle;
  final String nameLabel;
  final String nameHint;
  final Future<String?> Function(String email, String password) onLogin;
  final Future<String?> Function(String name, String email, String password)
  onSignup;

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _signUp = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _setMode(bool signUp) {
    if (_signUp == signUp || _submitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _signUp = signUp;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_signUp && name.isEmpty) {
      setState(() => _error = 'Enter ${widget.nameLabel.toLowerCase()}.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (_signUp && password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (!_signUp && password.isEmpty) {
      setState(() => _error = 'Enter your password.');
      return;
    }
    if (_signUp && password != _confirmController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    String? error;
    try {
      error = _signUp
          ? await widget.onSignup(name, email, password)
          : await widget.onLogin(email, password);
    } catch (exception, stackTrace) {
      debugPrint('Authentication failed: $exception\n$stackTrace');
      error = 'Something went wrong: $exception';
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    return AuthDecoratedBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOutExpo,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(_signUp ? .08 : -.08, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _signUp ? widget.signupTitle : widget.loginTitle,
                key: ValueKey(_signUp),
                textAlign: TextAlign.center,
                style: AppTextStyles.pageTitle.copyWith(fontSize: 30),
              ),
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
                    signUpSelected: _signUp,
                    onChanged: _setMode,
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutExpo,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, animation) {
                      return ClipRect(
                        child: FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(_signUp ? 1 : -1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: _signUp
                        ? _SignupFields(
                            key: const ValueKey('signup-fields'),
                            nameController: _nameController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmController: _confirmController,
                            nameLabel: widget.nameLabel,
                            nameHint: widget.nameHint,
                          )
                        : _LoginFields(
                            key: const ValueKey('login-fields'),
                            emailController: _emailController,
                            passwordController: _passwordController,
                          ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  if (!_signUp)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?'),
                      ),
                    )
                  else
                    const SizedBox(height: 22),
                  if (!_signUp) const SizedBox(height: 12),
                  AuthPrimaryButton(
                    label: _signUp ? 'Sign up' : 'Log in',
                    loading: _submitting,
                    onPressed: _submitting ? null : _submit,
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

class _LoginFields extends StatelessWidget {
  const _LoginFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _EmailField(controller: emailController),
      const SizedBox(height: 14),
      _PasswordField(controller: passwordController, label: 'Password'),
    ],
  );
}

class _SignupFields extends StatelessWidget {
  const _SignupFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.nameLabel,
    required this.nameHint,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String nameLabel;
  final String nameHint;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        controller: nameController,
        textInputAction: TextInputAction.next,
        decoration: authFieldDecoration(
          label: nameLabel,
          hint: nameHint,
          icon: Icons.badge_outlined,
        ),
      ),
      const SizedBox(height: 14),
      _EmailField(controller: emailController),
      const SizedBox(height: 14),
      _PasswordField(controller: passwordController, label: 'Password'),
      const SizedBox(height: 14),
      _PasswordField(
        controller: confirmController,
        label: 'Confirm Password',
        submit: true,
      ),
    ],
  );
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    decoration: authFieldDecoration(
      label: 'Email',
      hint: 'you@example.com',
      icon: Icons.mail_outline_rounded,
    ),
  );
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    this.submit = false,
  });

  final TextEditingController controller;
  final String label;
  final bool submit;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: true,
    textInputAction: submit ? TextInputAction.done : TextInputAction.next,
    decoration: authFieldDecoration(
      label: label,
      icon: Icons.lock_outline_rounded,
    ),
  );
}
