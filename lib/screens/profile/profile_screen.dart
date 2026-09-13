import 'package:flutter/material.dart';
import '../../core/widget/empty_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const EmptyState(
    icon: Icons.person_rounded,
    title: 'Player profile',
    message: 'Profile preferences and settings are coming next.',
  );
}
