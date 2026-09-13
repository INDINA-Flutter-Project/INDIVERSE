import 'package:flutter/material.dart';
import '../widgets/auth_login_form.dart';

class DeveloperLoginScreen extends StatelessWidget {
  const DeveloperLoginScreen({super.key});

  @override
  Widget build(BuildContext context) => AuthLoginForm(
    title: 'Developer login',
    subtitle: 'Manage your games, activities, and creator matches.',
    icon: Icons.code_rounded,
    onLogin: () => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Developer Home is the next UI flow.')),
    ),
  );
}
