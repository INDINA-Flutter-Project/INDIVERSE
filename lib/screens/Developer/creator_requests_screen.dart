import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/widget/empty_state.dart';
import '../../core/widget/glass_action.dart';
import '../../models/creator_campaign.dart';
import '../../models/creator_request.dart';
import '../../models/game.dart';
import '../../service/creator_request_service.dart';
import '../../service/url_launcher_service.dart';

enum _RequestFilter { all, pending, accepted, declined }

extension on _RequestFilter {
  String get label => switch (this) {
    _RequestFilter.all => 'All',
    _RequestFilter.pending => 'Pending',
    _RequestFilter.accepted => 'Accepted',
    _RequestFilter.declined => 'Declined',
  };

  bool matches(CreatorRequest request) => switch (this) {
    _RequestFilter.all => true,
    _RequestFilter.pending => request.status == 'pending',
    _RequestFilter.accepted => request.status == 'accepted',
    _RequestFilter.declined => request.status == 'declined',
  };
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

String _formatSubscribers(int count) {
  if (count >= 1000000) {
    final millions = count / 1000000;
    final digits = millions >= 10 ? 0 : 2;
    return '${_trimTrailingZeros(millions.toStringAsFixed(digits))}M';
  }
  if (count >= 1000) {
    final thousands = count / 1000;
    final digits = thousands >= 100 ? 0 : 1;
    return '${_trimTrailingZeros(thousands.toStringAsFixed(digits))}K';
  }
  return '$count';
}

String _trimTrailingZeros(String value) {
  if (!value.contains('.')) return value;
  return value
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

/// Shows the developer-side requests from content creators wanting to
/// cover a single campaign. Always scoped to [campaign.id] — never mixes
/// in requests belonging to other campaigns.
class CreatorRequestsScreen extends StatefulWidget {
  const CreatorRequestsScreen({
    super.key,
    required this.campaign,
    required this.game,
  });

  final CreatorCampaign campaign;

  /// The campaign's game, resolved from the developer-owned games list
  /// already available in Creator Outreach. May be null if the game can't
  /// be resolved — the header falls back to a safe label in that case.
  final Game? game;

  @override
  State<CreatorRequestsScreen> createState() => _CreatorRequestsScreenState();
}

class _CreatorRequestsScreenState extends State<CreatorRequestsScreen> {
  late Future<List<CreatorRequest>> _requestsFuture;
  _RequestFilter _filter = _RequestFilter.all;
  final Set<int> _busyRequestIds = {};

  @override
  void initState() {
    super.initState();
    _requestsFuture = _load();
  }

  Future<List<CreatorRequest>> _load() {
    return CreatorRequestService().getRequestsForCampaign(
      widget.campaign.id,
    );
  }

  void _retry() => setState(() {
    _requestsFuture = _load();
  });

  Future<void> _updateStatus(CreatorRequest request, String status) async {
    if (_busyRequestIds.contains(request.id)) return;

    setState(() => _busyRequestIds.add(request.id));
    try {
      await CreatorRequestService().updateRequestStatus(
        requestId: request.id,
        status: status,
      );
      if (!mounted) return;
      final future = _load();
      setState(() {
        _requestsFuture = future;
      });
      await future;
    } catch (e, st) {
      debugPrint('updateRequestStatus failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update this request. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyRequestIds.remove(request.id));
    }
  }

  Future<void> _openChannel(String channelUrl) async {
    final opened = await UrlLauncherService.openExternalUrl(channelUrl);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this channel link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Requests')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          Text(
            widget.game?.name ?? 'Unknown game',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 4),
          Text(
            '${_platformLabel(widget.campaign.platform)} • '
            '${_contentTypeLabel(widget.campaign.contentType)}',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<CreatorRequest>>(
            future: _requestsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return _RequestsError(onRetry: _retry);
              }

              final requests = snapshot.data ?? const <CreatorRequest>[];

              if (requests.isEmpty) {
                return const EmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No creator requests yet.',
                  message:
                      "When creators request to cover this campaign, "
                      "they'll appear here.",
                );
              }

              final counts = {
                for (final filter in _RequestFilter.values)
                  filter: requests.where(filter.matches).length,
              };
              final filtered = requests.where(_filter.matches).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _RequestFilter.values
                          .map(
                            (filter) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _filter == filter
                                  ? GlassAction(
                                      label:
                                          '${filter.label} (${counts[filter]})',
                                      onPressed: () => setState(() {
                                        _filter = filter;
                                      }),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 9,
                                      ),
                                    )
                                  : ChoiceChip(
                                      label: Text(
                                        '${filter.label} (${counts[filter]})',
                                      ),
                                      selected: false,
                                      labelStyle: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                      onSelected: (_) => setState(() {
                                        _filter = filter;
                                      }),
                                    ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No ${_filter.label.toLowerCase()} requests.',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                    )
                  else
                    for (var i = 0; i < filtered.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _RequestCard(
                        request: filtered[i],
                        isBusy: _busyRequestIds.contains(filtered[i].id),
                        onAccept: () =>
                            _updateStatus(filtered[i], 'accepted'),
                        onDecline: () =>
                            _updateStatus(filtered[i], 'declined'),
                        onViewChannel: () =>
                            _openChannel(filtered[i].creator.channelUrl),
                      ),
                    ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.isBusy,
    required this.onAccept,
    required this.onDecline,
    required this.onViewChannel,
  });

  final CreatorRequest request;
  final bool isBusy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewChannel;

  @override
  Widget build(BuildContext context) {
    final creator = request.creator;
    final genres = creator.genres.take(3).join(' • ');

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
          Text(
            creator.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            '${_formatSubscribers(creator.subscribers)} subscribers',
            style: AppTextStyles.bodyMuted,
          ),
          if (genres.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              genres,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              request.message,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body,
            ),
          ],
          const SizedBox(height: 12),
          _StatusBadge(status: request.status),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewChannel,
              child: const Text('View Channel'),
            ),
          ),
          if (request.status == 'pending') ...[
            const SizedBox(height: 8),
            if (isBusy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onAccept,
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'accepted' => ('Accepted', AppColors.success),
      'declined' => ('Declined', AppColors.error),
      _ => ('Pending', AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: AppTextStyles.label.copyWith(color: color)),
    );
  }
}

class _RequestsError extends StatelessWidget {
  const _RequestsError({required this.onRetry});

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
          'Unable to load requests',
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
