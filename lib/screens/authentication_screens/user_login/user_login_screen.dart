import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../service/auth_service.dart';
import '../../player/player_shell.dart';
import '../../preferences/user_preferences_screen.dart';
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
    } on AuthException catch (exception) {
      return exception.message;
    } catch (exception, stackTrace) {
      debugPrint('User signIn failed: $exception\n$stackTrace');
      return 'Something went wrong: $exception';
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

  Future<String?> _signup(
    BuildContext context,
    String displayName,
    String email,
    String password,
  ) async {
    final authService = AuthService();
    try {
      final response = await authService.signUp(
        email: email,
        password: password,
        role: 'user',
        displayName: displayName,
      );
      if (!context.mounted) return null;
      if (response.session == null) {
        return 'Check your email to confirm your account, then log in.';
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const UserPreferencesScreen(openedFromSignup: true),
        ),
        (_) => false,
      );
      return null;
    } on AuthException catch (exception) {
      return exception.message;
    } catch (exception, stackTrace) {
      debugPrint('User signUp failed: $exception\n$stackTrace');
      return 'Something went wrong: $exception';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: AuthLoginForm(
        loginTitle: 'User login',
        signupTitle: 'User sign up',
        subtitle: 'Discover and wishlist Saudi indie games.',
        nameLabel: 'Display Name',
        nameHint: 'e.g. Ahmed',
        onLogin: (email, password) => _login(context, email, password),
        onSignup: (name, email, password) =>
            _signup(context, name, email, password),
      ),
    );
  }
}
