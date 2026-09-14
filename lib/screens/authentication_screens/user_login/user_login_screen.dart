import 'package:flutter/material.dart';
import '../../player/player_shell.dart';
import '../widgets/auth_login_form.dart';

class UserLoginScreen extends StatelessWidget {
  const UserLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AuthLoginForm(
        title: 'User login',
        subtitle: 'Discover and wishlist Saudi indie games.',
        icon: Icons.sports_esports_rounded,
        onLogin: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PlayerShell()),
          (_) => false,
        ),
      ),
    );
  }
}
