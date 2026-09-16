import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/creator_campaign.dart';
import '../../models/game.dart';
import '../../service/creator_campaign_service.dart';
import 'campaign_form_screen.dart';
import 'creator_requests_screen.dart';

class DeveloperCreatorOutreachScreen extends StatefulWidget {
  const DeveloperCreatorOutreachScreen({super.key, required this.games});

  /// Always the current developer's own games, as loaded by
  /// Database.getGamesByDeveloper in DeveloperShell.
  final List<Game> games;

  @override
  State<DeveloperCreatorOutreachScreen> createState() =>
      _DeveloperCreatorOutreachScreenState();
}

class _DeveloperCreatorOutreachScreenState
    extends State<DeveloperCreatorOutreachScreen> {
  late Future<List<CreatorCampaign>> _campaignsFuture;

  @override
  void initState() {
    super.initState();
    _campaignsFuture = _load();
  }

  Future<List<CreatorCampaign>> _load() {
    final gameIds = widget.games.map((game) => game.id).toList();
    return CreatorCampaignService().getCampaignsForDeveloper(gameIds);
  }

  void _retry() => setState(() {
    _campaignsFuture = _load();
  });

  Future<void> _reload() async {
    final future = _load();
    setState(() {
      _campaignsFuture = future;
    });
    try {
      await future;
    } catch (_) {
      // Already surfaced via FutureBuilder's error state.
    }
  }

  Future<void> _openCreateCampaign() async {
    final created = await Navigator.push<CreatorCampaign>(
      context,
      MaterialPageRoute(
        builder: (_) => CampaignFormScreen(games: widget.games),
      ),
    );
    if (created != null) await _reload();
  }

  Future<void> _openEditCampaign(CreatorCampaign campaign) async {
    final updated = await Navigator.push<CreatorCampaign>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CampaignFormScreen(games: widget.games, campaign: campaign),
      ),
    );
    if (updated != null) await _reload();
  }

  void _openCreatorRequests(CreatorCampaign campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatorRequestsScreen(
          campaign: campaign,
          game: _gameFor(campaign.gameId, widget.games),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Creator Outreach', style: AppTextStyles.pageTitle),
            ),
            IconButton(
              onPressed: _openCreateCampaign,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Connect with content creators and get your game in front of '
          'more players.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<CreatorCampaign>>(
          future: _campaignsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return _CampaignsError(onRetry: _retry);
            }

            final campaigns = snapshot.data ?? const <CreatorCampaign>[];

            if (campaigns.isEmpty) {
              return _EmptyCampaigns(
                hasGames: widget.games.isNotEmpty,
                onCreate: _openCreateCampaign,
              );
            }

            return Column(
              children: [
                for (var i = 0; i < campaigns.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _CampaignCard(
                    campaign: campaigns[i],
                    games: widget.games,
                    onEdit: () => _openEditCampaign(campaigns[i]),
                    onRequests: () => _openCreatorRequests(campaigns[i]),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

Game? _gameFor(int gameId, List<Game> games) {
  for (final game in games) {
    if (game.id == gameId) return game;
  }
  return null;
}

String _platformLabel(String value) => switch (value) {
  'youtube' => 'YouTube',
  'twitch' => 'Twitch',
  'kick' => 'Kick',
  _ => value,
};

String _contentTypeLabel(String value) => switch (value) {
  'gameplay' => 'Gameplay',
  'first_impressions' => 'First Impressions',
  'review' => 'Review',
  'livestream' => 'Livestream',
  _ => value,
};

String _statusLabel(String value) => switch (value) {
  'active' => 'Active',
  'paused' => 'Paused',
  'closed' => 'Closed',
  _ => value,
};

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.games,
    required this.onEdit,
    required this.onRequests,
  });

  final CreatorCampaign campaign;
  final List<Game> games;
  final VoidCallback onEdit;
  final VoidCallback onRequests;

  @override
  Widget build(BuildContext context) {
    final game = _gameFor(campaign.gameId, games);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: game?.coverImage != null
                      ? Image.network(
                          game!.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const ColoredBox(color: AppColors.background),
                        )
                      : const ColoredBox(color: AppColors.background),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game?.name ?? 'Unknown game',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (game != null && game.genres.isNotEmpty)
                      Text(
                        game.genres.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMuted,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CampaignDetailRow(
            label: 'Platform',
            value: _platformLabel(campaign.platform),
          ),
          _CampaignDetailRow(
            label: 'Content wanted',
            value: _contentTypeLabel(campaign.contentType),
          ),
          _CampaignDetailRow(
            label: 'Keys available',
            value: '${campaign.keyCount}',
          ),
          _CampaignDetailRow(
            label: 'Campaign status',
            value: _statusLabel(campaign.status),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onEdit,
              child: const Text('Edit Campaign'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onRequests,
              child: const Text('Creator Requests'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignDetailRow extends StatelessWidget {
  const _CampaignDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMuted)),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _EmptyCampaigns extends StatelessWidget {
  const _EmptyCampaigns({required this.hasGames, required this.onCreate});

  final bool hasGames;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            hasGames ? Icons.campaign_outlined : Icons.sports_esports_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            hasGames
                ? 'No creator campaigns yet.'
                : 'Add a game before creating a campaign.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            hasGames
                ? 'Create a campaign to start connecting your game with '
                      'content creators.'
                : 'Publish a game first, then come back to create your '
                      'first outreach campaign.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onCreate,
            child: const Text('Create Campaign'),
          ),
        ],
      ),
    );
  }
}

class _CampaignsError extends StatelessWidget {
  const _CampaignsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_rounded, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Unable to load campaigns',
          style: TextStyle(fontFamily: 'Michroma', fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check your connection and try again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tomorrow',
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
