import 'package:flutter/material.dart';
import '../../core/widget/empty_state.dart';
import '../../service/auth_service.dart';
import '../authentication_screens/login_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await AuthService().signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Expanded(
        child: EmptyState(
          icon: Icons.person_rounded,
          title: 'Player profile',
          message: 'Profile preferences and settings are coming next.',
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(24),
        child: OutlinedButton.icon(
          onPressed: () => _signOut(context),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
        ),
      ),
    ],
  );
}
