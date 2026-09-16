import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/user_preferences.dart';
import '../../service/database.dart';
import '../player/player_shell.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({
    super.key,
    this.initialPreferences,
    this.openedFromSignup = false,
  });

  final UserPreferences? initialPreferences;
  final bool openedFromSignup;

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  final _database = Database();
  final _genres = <String>{};
  final _platforms = <String>{};
  final _languages = <String>{};
  final _gameStages = <String>{};
  final _playStyles = <String>{};

  bool _saving = false;
  String? _error;

  static const _genreOptions = [
    'Action',
    'Adventure',
    'Horror',
    'Puzzle',
    'RPG',
    'Simulation',
    'Story Rich',
  ];
  static const _platformOptions = ['PC', 'Mobile', 'Console'];
  static const _languageOptions = ['Arabic', 'English', 'Both'];
  static const _stageOptions = ['Released', 'Demo', 'Coming Soon'];
  static const _styleOptions = [
    'Solo',
    'Multiplayer',
    'Story',
    'Competitive',
    'Casual',
  ];

  @override
  void initState() {
    super.initState();
    final preferences = widget.initialPreferences;
    if (preferences == null) return;
    _genres.addAll(preferences.genres);
    _platforms.addAll(preferences.platforms);
    _languages.addAll(preferences.languages);
    _gameStages.addAll(preferences.gameStages);
    _playStyles.addAll(preferences.playStyles);
  }

  Future<void> _save() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _error = 'You need to be signed in to save preferences.');
      return;
    }

    if (_genres.isEmpty) {
      setState(() => _error = 'Choose at least one genre.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _database.saveUserPreferences(
        UserPreferences(
          userId: userId,
          genres: _genres.toList(),
          platforms: _platforms.toList(),
          languages: _languages.toList(),
          gameStages: _gameStages.toList(),
          playStyles: _playStyles.toList(),
        ),
      );
    } catch (e, st) {
      debugPrint('Saving user preferences failed: $e\n$st');
      if (mounted) {
        setState(() => _error = 'Could not save preferences: $e');
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    if (!mounted) return;
    if (widget.openedFromSignup) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PlayerShell()),
        (_) => false,
      );
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.openedFromSignup
        ? 'Choose your preferences'
        : 'Edit preferences';
    final subtitle = widget.openedFromSignup
        ? 'Help INDIVERSE recommend games that match what you like.'
        : 'Update what you want to discover next.';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.openedFromSignup ? 'Preferences' : 'Settings'),
        automaticallyImplyLeading: !widget.openedFromSignup,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        children: [
          Text(title, style: AppTextStyles.pageTitle),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.bodyMuted),
          const SizedBox(height: 26),
          _PreferenceSection(
            title: 'Favorite genres',
            options: _genreOptions,
            selected: _genres,
            onChanged: _toggle,
          ),
          _PreferenceSection(
            title: 'Platforms',
            options: _platformOptions,
            selected: _platforms,
            onChanged: _toggle,
          ),
          _PreferenceSection(
            title: 'Language',
            options: _languageOptions,
            selected: _languages,
            onChanged: _toggle,
          ),
          _PreferenceSection(
            title: 'Game stage',
            options: _stageOptions,
            selected: _gameStages,
            onChanged: _toggle,
          ),
          _PreferenceSection(
            title: 'Play style',
            options: _styleOptions,
            selected: _playStyles,
            onChanged: _toggle,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.openedFromSignup ? 'Continue' : 'Save changes'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(Set<String> selected, String value) {
    setState(() {
      selected.contains(value) ? selected.remove(value) : selected.add(value);
    });
  }
}

class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;
  final void Function(Set<String> selected, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 17)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
                  selected: selected.contains(option),
                  onSelected: (_) => onChanged(selected, option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
