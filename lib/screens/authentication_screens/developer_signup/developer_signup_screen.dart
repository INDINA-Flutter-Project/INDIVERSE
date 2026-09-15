import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../service/auth_service.dart';
import '../../Developer/developer_shell.dart';
import '../widgets/auth_signup_form.dart';

class DeveloperSignupScreen extends StatefulWidget {
  const DeveloperSignupScreen({super.key});

  @override
  State<DeveloperSignupScreen> createState() => _DeveloperSignupScreenState();
}

class _DeveloperSignupScreenState extends State<DeveloperSignupScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<String?> _signup(String email, String password) async {
    final developerName = _nameController.text.trim();
    if (developerName.isEmpty) {
      return 'Enter your developer or studio name.';
    }

    final authService = AuthService();
    final AuthResponse response;
    try {
      response = await authService.signUp(
        email: email,
        password: password,
        role: 'developer',
        developerName: developerName,
      );
    } on AuthException catch (e) {
      return e.message;
    } catch (e, st) {
      debugPrint('Developer signUp failed: $e\n$st');
      return 'Something went wrong: $e';
    }

    if (!mounted) return null;

    if (response.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Check your email to confirm your account, then log in.',
          ),
        ),
      );
      Navigator.of(context).pop();
      return null;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DeveloperShell()),
      (_) => false,
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: AuthSignupForm(
        title: 'Create a developer account',
        subtitle: 'Manage your games, activities, and creator matches.',
        icon: Icons.code_rounded,
        extraFieldController: _nameController,
        extraFieldLabel: 'Developer / Studio Name',
        extraFieldHint: 'e.g. Sandstorm Games',
        onSignup: _signup,
        onHaveAccount: () => Navigator.of(context).pop(),
      ),
    );
  }
}
