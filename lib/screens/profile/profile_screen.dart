import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/widget/empty_state.dart';
import '../../models/user_preferences.dart';
import '../../service/auth_service.dart';
import '../../service/database.dart';
import '../authentication_screens/login_selection_screen.dart';
import '../preferences/user_preferences_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onPreferencesChanged});

  /// Notified after preferences are successfully edited, so an ancestor
  /// (PlayerShell) can refresh whatever it derives from them (e.g. Home's
  /// "For you" section) without an app restart.
  final VoidCallback? onPreferencesChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _database = Database();
  late Future<UserPreferences?> _preferencesFuture;

  @override
  void initState() {
    super.initState();
    _preferencesFuture = _loadPreferences();
  }

  Future<UserPreferences?> _loadPreferences() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return Future.value();
    return _database.getUserPreferences(userId);
  }

  void _refreshPreferences() {
    setState(() {
      _preferencesFuture = _loadPreferences();
    });
  }

  Future<void> _editPreferences(UserPreferences? preferences) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => UserPreferencesScreen(initialPreferences: preferences),
      ),
    );

    if (changed == true) {
      _refreshPreferences();
      widget.onPreferencesChanged?.call();
    }
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserPreferences?>(
      future: _preferencesFuture,
      builder: (context, snapshot) {
        final preferences = snapshot.data;

        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          children: [
            const Text('Player profile', style: AppTextStyles.pageTitle),
            const SizedBox(height: 8),
            const Text(
              'Preview and update what INDIVERSE uses to shape your discovery.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 24),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.hasError)
              EmptyState(
                icon: Icons.tune_rounded,
                title: 'Preferences unavailable',
                message: snapshot.error.toString(),
              )
            else if (preferences == null)
              _PreferencesEmpty(onCreate: () => _editPreferences(null))
            else
              _PreferencesPreview(
                preferences: preferences,
                onEdit: () => _editPreferences(preferences),
              ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        );
      },
    );
  }
}

class _PreferencesEmpty extends StatelessWidget {
  const _PreferencesEmpty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primary, size: 42),
          const SizedBox(height: 14),
          const Text(
            'No preferences yet',
            style: AppTextStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your genres and play style so your game discovery feels more personal.',
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add preferences'),
          ),
        ],
      ),
    );
  }
}

class _PreferencesPreview extends StatelessWidget {
  const _PreferencesPreview({required this.preferences, required this.onEdit});

  final UserPreferences preferences;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your preferences',
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _PreferenceGroup(title: 'Genres', values: preferences.genres),
          _PreferenceGroup(title: 'Platforms', values: preferences.platforms),
          _PreferenceGroup(title: 'Language', values: preferences.languages),
          _PreferenceGroup(title: 'Game stage', values: preferences.gameStages),
          _PreferenceGroup(title: 'Play style', values: preferences.playStyles),
        ],
      ),
    );
  }
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMuted),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values)
                Chip(
                  label: Text(value),
                  backgroundColor: AppColors.primaryContainer,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
