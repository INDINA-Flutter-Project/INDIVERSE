import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/game.dart';
import '../../service/auth_service.dart';
import '../../service/database.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key, this.existingGame});

  final Game? existingGame;

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  late final _titleController = TextEditingController(
    text: widget.existingGame?.name ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.existingGame?.description ?? '',
  );
  bool _submitting = false;
  String? _error;
  String _selectedStatus = 'upcoming';

  bool get _isEditing => widget.existingGame != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      setState(() => _error = 'Game title is required.');
      return;
    }

    final existingGame = widget.existingGame;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (existingGame != null) {
        final updatedGame = Game(
          id: existingGame.id,
          name: title,
          description: description.isEmpty ? null : description,
          developer: existingGame.developer,
          developerId: existingGame.developerId,
          publisher: existingGame.publisher,
          genres: existingGame.genres,
          releaseDate: existingGame.releaseDate,
          priceUsd: existingGame.priceUsd,
          status: existingGame.status,
          shortDescription: existingGame.shortDescription,
          coverImage: existingGame.coverImage,
          arabicSupport: existingGame.arabicSupport,
          steamUrl: existingGame.steamUrl,
          extraLinks: existingGame.extraLinks,
          awards: existingGame.awards,
        );
        await Database().updateGame(updatedGame);
        if (!mounted) return;
        Navigator.pop(context, updatedGame);
        return;
      } else {
        final developerId = Supabase.instance.client.auth.currentUser?.id;
        if (developerId == null) {
          setState(
            () => _error =
                'You must be signed in as a developer to publish a game.',
          );
          return;
        }

        final developerName = AuthService().currentDeveloperName;
        if (developerName == null || developerName.isEmpty) {
          setState(
            () => _error =
                'Your account is missing a developer name — please sign out and sign up again.',
          );
          return;
        }

        await Database().addGame(
          Game(
            id: 0,
            name: title,
            description: description.isEmpty ? null : description,
            developer: developerName,
            developerId: developerId,
            status: _selectedStatus,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e, st) {
      debugPrint('${_isEditing ? 'updateGame' : 'addGame'} failed: $e\n$st');
      if (!mounted) return;
      setState(
        () => _error =
            'Could not ${_isEditing ? 'save changes' : 'publish game'}: $e',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Game' : 'Add New Game')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          _DeveloperTextField(
            label: 'Game Title',
            hint: 'Enter game title',
            controller: _titleController,
          ),
          const SizedBox(height: 14),
          _DeveloperTextField(
            label: 'Description',
            hint: 'Tell us about your game...',
            controller: _descriptionController,
            maxLines: 4,
          ),
          if (!_isEditing) ...[
            const SizedBox(height: 14),
            const Text('Status', style: AppTextStyles.bodyMuted),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'upcoming', label: Text('Upcoming')),
                ButtonSegment(value: 'released', label: Text('Released')),
              ],
              selected: {_selectedStatus},
              onSelectionChanged: (value) =>
                  setState(() => _selectedStatus = value.first),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _publish,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Publish Game'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperTextField extends StatelessWidget {
  const _DeveloperTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
