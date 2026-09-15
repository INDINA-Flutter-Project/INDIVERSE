import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../service/auth_service.dart';
import '../../player/player_shell.dart';
import '../widgets/auth_signup_form.dart';

class UserSignupScreen extends StatelessWidget {
  const UserSignupScreen({super.key});

  Future<String?> _signup(
    BuildContext context,
    String email,
    String password,
  ) async {
    final authService = AuthService();
    final AuthResponse response;
    try {
      response = await authService.signUp(
        email: email,
        password: password,
        role: 'user',
      );
    } on AuthException catch (e) {
      return e.message;
    } catch (e, st) {
      debugPrint('User signUp failed: $e\n$st');
      return 'Something went wrong: $e';
    }

    if (!context.mounted) return null;

    if (response.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check your email to confirm your account, then log in.'),
        ),
      );
      Navigator.of(context).pop();
      return null;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PlayerShell()),
      (_) => false,
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AuthSignupForm(
        title: 'Create a user account',
        subtitle: 'Discover and wishlist Saudi indie games.',
        icon: Icons.sports_esports_rounded,
        onSignup: (email, password) => _signup(context, email, password),
        onHaveAccount: () => Navigator.of(context).pop(),
      ),
    );
  }
}
