import 'package:flutter/material.dart';
import 'screens/auth/login_selection_screen.dart';

/// Decides which top-level experience the app should display.
/// Authentication/session routing will replace this temporary entry screen.
class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) => const LoginSelectionScreen();
}
