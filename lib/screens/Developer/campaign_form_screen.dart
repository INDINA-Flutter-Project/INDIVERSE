import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/creator_campaign.dart';
import '../../models/game.dart';
import '../../service/creator_campaign_service.dart';

/// Handles both creating a new campaign and editing an existing one.
///
/// Pass [campaign] to open in edit mode, pre-filled with its current
/// values. Leave it null to create a new campaign.
class CampaignFormScreen extends StatefulWidget {
  const CampaignFormScreen({super.key, required this.games, this.campaign});

  /// Must only ever be the current developer's own games — the games list
  /// passed down from DeveloperShell via DeveloperCreatorOutreachScreen.
  final List<Game> games;

  /// The campaign being edited, or null when creating a new one.
  final CreatorCampaign? campaign;

  bool get isEditing => campaign != null;

  @override
  State<CampaignFormScreen> createState() => _CampaignFormScreenState();
}

class _CampaignFormScreenState extends State<CampaignFormScreen> {
  final _keyCountController = TextEditingController();

  Game? _selectedGame;
  String _platform = 'youtube';
  String _contentType = 'gameplay';
  String _status = 'active';
  bool _submitting = false;
  String? _error;

  /// True when editing a campaign whose game_id isn't among this
  /// developer's current games — the developer must pick a valid one.
  bool _selectedGameMissing = false;

  bool get _hasGames => widget.games.isNotEmpty;
  bool get _isEditing => widget.campaign != null;

  @override
  void initState() {
    super.initState();
    final campaign = widget.campaign;
    if (campaign != null) {
      _platform = campaign.platform;
      _contentType = campaign.contentType;
      _status = campaign.status;
      _keyCountController.text = '${campaign.keyCount}';

      Game? match;
      for (final game in widget.games) {
        if (game.id == campaign.gameId) {
          match = game;
          break;
        }
      }
      if (match != null) {
        _selectedGame = match;
      } else {
        _selectedGameMissing = true;
      }
    } else if (_hasGames) {
      _selectedGame = widget.games.first;
    }
  }

  @override
  void dispose() {
    _keyCountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_hasGames || _submitting) return;

    final game = _selectedGame;
    if (game == null) {
      setState(() => _error = 'Select a game.');
      return;
    }

    final keyCount = int.tryParse(_keyCountController.text.trim());
    if (keyCount == null || keyCount < 0) {
      setState(() => _error = 'Enter a valid number of keys (0 or more).');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final service = CreatorCampaignService();
      final campaign = _isEditing
          ? await service.updateCampaign(
              campaignId: widget.campaign!.id,
              gameId: game.id,
              platform: _platform,
              contentType: _contentType,
              keyCount: keyCount,
              status: _status,
            )
          : await service.createCampaign(
              gameId: game.id,
              platform: _platform,
              contentType: _contentType,
              keyCount: keyCount,
              status: _status,
            );
      if (!mounted) return;
      Navigator.pop(context, campaign);
    } catch (e, st) {
      final action = _isEditing ? 'updateCampaign' : 'createCampaign';
      debugPrint('$action failed: $e\n$st');
      if (!mounted) return;
      setState(
        () => _error =
            'Could not ${_isEditing ? 'save changes' : 'create campaign'}: $e',
      );
      if (_isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save changes. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Campaign' : 'Create Campaign'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          if (!_hasGames) ...[
            Text(
              'Add a game before creating a campaign.',
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 20),
          ] else ...[
            const Text('Game', style: AppTextStyles.bodyMuted),
            const SizedBox(height: 6),
            if (_selectedGameMissing) ...[
              Text(
                "This campaign's game is no longer in your games list. "
                'Select a game to continue.',
                style: AppTextStyles.bodyMuted.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 6),
            ],
            DropdownButtonFormField<Game>(
              initialValue: _selectedGame,
              hint: const Text('Select a game'),
              items: widget.games
                  .map(
                    (game) =>
                        DropdownMenuItem(value: game, child: Text(game.name)),
                  )
                  .toList(),
              onChanged: (game) => setState(() {
                _selectedGame = game;
                _selectedGameMissing = false;
              }),
            ),
            const SizedBox(height: 14),
          ],
          const Text('Platform', style: AppTextStyles.bodyMuted),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _platform,
            items: const [
              DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
              DropdownMenuItem(value: 'twitch', child: Text('Twitch')),
              DropdownMenuItem(value: 'kick', child: Text('Kick')),
            ],
            onChanged: (value) => setState(() => _platform = value!),
          ),
          const SizedBox(height: 14),
          const Text('Content Type', style: AppTextStyles.bodyMuted),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _contentType,
            items: const [
              DropdownMenuItem(value: 'gameplay', child: Text('Gameplay')),
              DropdownMenuItem(
                value: 'first_impressions',
                child: Text('First Impressions'),
              ),
              DropdownMenuItem(value: 'review', child: Text('Review')),
              DropdownMenuItem(
                value: 'livestream',
                child: Text('Livestream'),
              ),
            ],
            onChanged: (value) => setState(() => _contentType = value!),
          ),
          const SizedBox(height: 14),
          const Text('Keys Available', style: AppTextStyles.bodyMuted),
          const SizedBox(height: 6),
          TextField(
            controller: _keyCountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'e.g. 5'),
          ),
          const SizedBox(height: 14),
          const Text('Campaign Status', style: AppTextStyles.bodyMuted),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _status,
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'paused', child: Text('Paused')),
              DropdownMenuItem(value: 'closed', child: Text('Closed')),
            ],
            onChanged: (value) => setState(() => _status = value!),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (!_hasGames || _submitting) ? null : _submit,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Create Campaign'),
            ),
          ),
        ],
      ),
    );
  }
}
