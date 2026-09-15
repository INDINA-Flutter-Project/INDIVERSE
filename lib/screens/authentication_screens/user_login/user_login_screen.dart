import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../service/auth_service.dart';
import '../../player/player_shell.dart';
import '../user_signup/user_signup_screen.dart';
import '../widgets/auth_login_form.dart';

class UserLoginScreen extends StatelessWidget {
  const UserLoginScreen({super.key});

  Future<String?> _login(
    BuildContext context,
    String email,
    String password,
  ) async {
    final authService = AuthService();
    try {
      await authService.signIn(email: email, password: password);
    } on AuthException catch (e) {
      return e.message;
    } catch (e, st) {
      debugPrint('User signIn failed: $e\n$st');
      return 'Something went wrong: $e';
    }

    if (authService.currentRole != 'user') {
      await authService.signOut();
      return 'This account is a developer account. Use Developer login instead.';
    }

    if (!context.mounted) return null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PlayerShell()),
      (_) => false,
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: AuthLoginForm(
        title: 'User login',
        subtitle: 'Discover and wishlist Saudi indie games.',
        icon: Icons.sports_esports_rounded,
        onLogin: (email, password) => _login(context, email, password),
        onCreateAccount: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserSignupScreen()),
        ),
      ),
    );
  }
}
