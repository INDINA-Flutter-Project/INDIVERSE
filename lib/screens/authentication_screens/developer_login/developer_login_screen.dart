import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../service/auth_service.dart';
import '../../Developer/developer_shell.dart';
import '../developer_signup/developer_signup_screen.dart';
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
    } on AuthException catch (e) {
      return e.message;
    } catch (e, st) {
      debugPrint('Developer signIn failed: $e\n$st');
      return 'Something went wrong: $e';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AuthLoginForm(
        title: 'Developer login',
        subtitle: 'Manage your games, activities, and creator matches.',
        icon: Icons.code_rounded,
        onLogin: (email, password) => _login(context, email, password),
        onCreateAccount: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeveloperSignupScreen()),
        ),
      ),
    );
  }
}
