import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../service/auth_service.dart';
import '../../preferences/user_preferences_screen.dart';
import '../widgets/auth_signup_form.dart';

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<String?> _signup(String email, String password) async {
    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      return 'Enter your display name.';
    }

    final authService = AuthService();
    final AuthResponse response;
    try {
      response = await authService.signUp(
        email: email,
        password: password,
        role: 'user',
        displayName: displayName,
      );
    } on AuthException catch (e) {
      return e.message;
    } catch (e, st) {
      debugPrint('User signUp failed: $e\n$st');
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
      MaterialPageRoute(
        builder: (_) => const UserPreferencesScreen(openedFromSignup: true),
      ),
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
        title: 'Create a user account',
        subtitle: 'Discover and wishlist Saudi indie games.',
        icon: Icons.sports_esports_rounded,
        extraFieldController: _displayNameController,
        extraFieldLabel: 'Display Name',
        extraFieldHint: 'e.g. Ahmed',
        onSignup: _signup,
        onHaveAccount: () => Navigator.of(context).pop(),
      ),
    );
  }
}
