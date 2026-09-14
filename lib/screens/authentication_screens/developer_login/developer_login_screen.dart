import 'package:flutter/material.dart';
import '../../Developer/developer_shell.dart';
import '../widgets/auth_login_form.dart';

class DeveloperLoginScreen extends StatelessWidget {
  const DeveloperLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AuthLoginForm(
        title: 'Developer login',
        subtitle: 'Manage your games, activities, and creator matches.',
        icon: Icons.code_rounded,
        onLogin: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DeveloperShell()),
        ),
      ),
    );
  }
}
