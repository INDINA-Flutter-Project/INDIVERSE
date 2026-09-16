import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../service/auth_service.dart';
import '../../Developer/developer_shell.dart';
import '../widgets/auth_login_form.dart';

class DeveloperLoginScreen extends StatelessWidget {
  const DeveloperLoginScreen({super.key});

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
      debugPrint('Developer signIn failed: $exception\n$stackTrace');
      return 'Something went wrong: $exception';
    }
    if (authService.currentRole != 'developer') {
      await authService.signOut();
      return 'This account is a user account. Use User login instead.';
    }
    if (!context.mounted) return null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DeveloperShell()),
      (_) => false,
    );
    return null;
  }

  Future<String?> _signup(
    BuildContext context,
    String developerName,
    String email,
    String password,
  ) async {
    final authService = AuthService();
    try {
      final response = await authService.signUp(
        email: email,
        password: password,
        role: 'developer',
        developerName: developerName,
      );
      if (!context.mounted) return null;
      if (response.session == null) {
        return 'Check your email to confirm your account, then log in.';
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DeveloperShell()),
        (_) => false,
      );
      return null;
    } on AuthException catch (exception) {
      return exception.message;
    } catch (exception, stackTrace) {
      debugPrint('Developer signUp failed: $exception\n$stackTrace');
      return 'Something went wrong: $exception';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: AuthLoginForm(
        loginTitle: 'Developer login',
        signupTitle: 'Developer sign up',
        subtitle: 'Manage your games, activities, and creator matches.',
        nameLabel: 'Developer / Studio Name',
        nameHint: 'e.g. Sandstorm Games',
        onLogin: (email, password) => _login(context, email, password),
        onSignup: (name, email, password) =>
            _signup(context, name, email, password),
      ),
    );
  }
}
