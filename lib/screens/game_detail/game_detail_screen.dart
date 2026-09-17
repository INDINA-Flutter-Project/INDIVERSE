import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
import '../../models/game_event.dart';
import '../../service/game_event_service.dart';
import '../../service/playtest_interest_service.dart';
import '../../service/url_launcher_service.dart';

class GameDetailsScreen extends StatefulWidget {
  const GameDetailsScreen({
    super.key,
    required this.game,
    required this.initiallySaved,
    required this.onWishlist,
  });
  final Game game;
  final bool initiallySaved;
  final VoidCallback onWishlist;

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

enum _InterestState { loading, error, notInterested, interested }

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late bool saved = widget.initiallySaved;
  _InterestState _interestState = _InterestState.loading;
  bool _playtestBusy = false;

  List<GameEvent> _events = const [];
  bool _eventsLoading = true;
  String? _eventsError;

  @override
  void initState() {
    super.initState();
    _loadInterestState();
    _loadEvents();
  }

  /// Loads independently of Playtesting/the rest of the screen — a failure
  /// here must never block or crash Game Details, only the "Game activity"
  /// events rows show an inline error.
  Future<void> _loadEvents() async {
    setState(() {
      _eventsLoading = true;
      _eventsError = null;
    });
    try {
      final events = await GameEventService().getEventsForGame(
        widget.game.id,
      );
      if (!mounted) return;
      setState(() => _events = events);
    } catch (e, st) {
      debugPrint('getEventsForGame (player) failed: $e\n$st');
      if (!mounted) return;
      setState(() => _eventsError = 'Could not load activity.');
    } finally {
      if (mounted) setState(() => _eventsLoading = false);
    }
  }

  List<Widget> _buildActivityChildren() {
    if (_eventsLoading) {
      return const [
        _ActivityStatusRow(
          icon: Icons.event_outlined,
          text: 'Loading activity…',
          trailing: _Spinner(),
        ),
      ];
    }
    if (_eventsError != null) {
      return [
        _ActivityStatusRow(
          icon: Icons.event_busy_outlined,
          text: _eventsError!,
          trailing: const _RetryPill(),
          onTap: _loadEvents,
        ),
      ];
    }
    if (_events.isEmpty) {
      return const [
        _ActivityStatusRow(
          icon: Icons.event_outlined,
          text: 'No activity yet.',
        ),
      ];
    }
    final rows = <Widget>[];
    for (var i = 0; i < _events.length; i++) {
      if (i > 0) {
        rows.add(const Divider(color: AppColors.border, height: 24));
      }
      rows.add(_EventRow(event: _events[i]));
    }
    return rows;
  }

  Future<void> _loadInterestState() async {
    final isUpcoming = widget.game.status?.trim().toLowerCase() == 'upcoming';

    debugPrint('PLAYTEST DEBUG gameId=${widget.game.id}');
    debugPrint('PLAYTEST DEBUG gameName=${widget.game.name}');
    debugPrint('PLAYTEST DEBUG status=${widget.game.status}');
    debugPrint(
      'PLAYTEST DEBUG user=${Supabase.instance.client.auth.currentUser?.id}',
    );
    debugPrint(
      'PLAYTEST DEBUG role=${Supabase.instance.client.auth.currentUser?.userMetadata?['role']}',
    );
    debugPrint('PLAYTEST DEBUG visibilityCondition=$isUpcoming');

    if (!isUpcoming) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() => _interestState = _InterestState.error);
      return;
    }

    if (mounted) setState(() => _interestState = _InterestState.loading);
    try {
      final interested = await PlaytestInterestService().hasInterest(
        gameId: widget.game.id,
        playerId: userId,
      );
      if (!mounted) return;
      setState(
        () => _interestState = interested
            ? _InterestState.interested
            : _InterestState.notInterested,
      );
    } catch (e, st) {
      debugPrint('hasInterest failed: $e\n$st');
      if (e is PostgrestException) {
        debugPrint(
          'PLAYTEST DEBUG postgrest message=${e.message} code=${e.code} '
          'details=${e.details} hint=${e.hint}',
        );
      }
      if (!mounted) return;
      setState(() => _interestState = _InterestState.error);
    }
  }

  /// One-time submission: only callable from [_InterestState.notInterested].
  /// This UI never cancels or toggles an existing request — once submitted,
  /// the interest row is permanent for the player.
  Future<void> _submitInterest() async {
    if (_playtestBusy || _interestState != _InterestState.notInterested) {
      return;
    }
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _playtestBusy = true);
    try {
      await PlaytestInterestService().registerInterest(gameId: widget.game.id);
      if (!mounted) return;
      setState(() => _interestState = _InterestState.interested);
    } catch (e, st) {
      debugPrint('playtest interest submission failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _playtestBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final steamUrl = game.steamUrl?.trim();
    final websiteUrl = game.extraLinks?.trim();
    final hasSteam = steamUrl != null && steamUrl.isNotEmpty;
    final hasWebsite = websiteUrl != null && websiteUrl.isNotEmpty;
    final isUpcoming = game.status?.trim().toLowerCase() == 'upcoming';
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 370,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _ImageOverlayButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ImageOverlayButton(
                  onPressed: () {
                    widget.onWishlist();
                    setState(() => saved = !saved);
                  },
                  icon: saved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: saved ? AppColors.primary : Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: game.coverImage != null
                  ? Image.network(
                      game.coverImage!,
                      width: double.infinity,
                      height: 380,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: AppColors.surface),
                    )
                  : const ColoredBox(color: AppColors.surface),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
            sliver: SliverList.list(
              children: [
                Text(
                  (game.status ?? 'Available').toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Tomorrow',
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.name,
                  style: const TextStyle(
                    fontFamily: 'Michroma',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'By ${game.developer ?? game.publisher ?? 'Independent studio'}',
                  style: const TextStyle(
                    fontFamily: 'Tomorrow',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: game.genres
                      .map((label) => Chip(label: Text(label)))
                      .toList(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'About',
                  style: TextStyle(
                    fontFamily: 'Michroma',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  game.description ??
                      game.shortDescription ??
                      'Details coming soon.',
                  style: const TextStyle(
                    fontFamily: 'Tomorrow',
                    fontSize: 16,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Game activity',
                  style: TextStyle(
                    fontFamily: 'Michroma',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      ..._buildActivityChildren(),
                      if (isUpcoming) ...[
                        const Divider(color: AppColors.border, height: 24),
                        switch (_interestState) {
                          _InterestState.loading => const _PlaytestingRow(
                            subtitle: 'Checking request…',
                            trailing: _Spinner(),
                          ),
                          _InterestState.error => _PlaytestingRow(
                            subtitle: 'Could not check request',
                            trailing: const _RetryPill(),
                            onTap: _loadInterestState,
                          ),
                          _InterestState.notInterested => _PlaytestingRow(
                            subtitle: _playtestBusy
                                ? 'Submitting request…'
                                : 'Apply to playtest this game',
                            trailing: _playtestBusy
                                ? const _Spinner()
                                : const _ApplyPill(),
                            onTap: _playtestBusy ? null : _submitInterest,
                            emphasize: !_playtestBusy,
                          ),
                          _InterestState.interested => const _PlaytestingRow(
                            subtitle: 'Request submitted',
                            trailing: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            ),
                            onTap: null,
                          ),
                        },
                      ],
                    ],
                  ),
                ),
                if (hasSteam || hasWebsite) ...[
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      if (hasSteam)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                UrlLauncherService.openExternalUrl(steamUrl),
                            icon: const Icon(Icons.sports_esports_rounded),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text('Steam'),
                            ),
                          ),
                        ),
                      if (hasSteam && hasWebsite) const SizedBox(width: 12),
                      if (hasWebsite)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                UrlLauncherService.openExternalUrl(websiteUrl),
                            icon: const Icon(Icons.public_rounded),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text('Website'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageOverlayButton extends StatelessWidget {
  const _ImageOverlayButton({
    required this.icon,
    required this.onPressed,
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black.withValues(alpha: 0.48),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 23),
          ),
        ),
      ),
    );
  }
}

/// A single real `game_events` row shown to players inside "Game activity".
/// Read-only — no onTap, no edit/delete affordance. Plain [ListTile] is safe
/// here (no onTap, no tileColor) exactly like the static row it replaced.
class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final GameEvent event;

  @override
  Widget build(BuildContext context) {
    final location = event.location;
    final subtitle = (location != null && location.isNotEmpty)
        ? '${event.scheduleLabel} · $location'
        : event.scheduleLabel;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: AppColors.primaryContainer,
        child: Icon(Icons.celebration_rounded, color: AppColors.primary),
      ),
      title: Text(event.title, style: const TextStyle(fontFamily: 'Michroma')),
      subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Tomorrow')),
    );
  }
}

/// A compact loading/error/empty row for the events section of "Game
/// activity". Uses the same Material → InkWell technique as
/// [_PlaytestingRow] so an optional tap target (e.g. Retry) is always safe.
class _ActivityStatusRow extends StatelessWidget {
  const _ActivityStatusRow({
    required this.icon,
    required this.text,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Tomorrow',
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// The Playtesting row inside "Game activity".
///
/// This intentionally does not use [ListTile]: ListTile paints its
/// background/ink splashes on the nearest ancestor [Material], and this row
/// lives inside a plain [Container] with an opaque background color (the
/// "Game activity" card). Without its own [Material] ancestor sitting
/// directly above it, that combination trips ListTile's
/// "background color or ink splashes may be invisible" assertion. Using
/// [Material] + [InkWell] directly gives this row its own ink surface and
/// also lets [emphasize] render a distinct actionable look (green accent)
/// for the not-submitted state, separate from ordinary informational rows.
class _PlaytestingRow extends StatelessWidget {
  const _PlaytestingRow({
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.emphasize = false,
  });

  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final fillColor = emphasize
        ? AppColors.primary.withValues(alpha: 0.08)
        : Colors.transparent;
    final borderColor = emphasize
        ? AppColors.primary.withValues(alpha: 0.4)
        : Colors.transparent;

    return Material(
      color: fillColor,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(
                  Icons.science_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Playtesting',
                      style: TextStyle(fontFamily: 'Michroma'),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Tomorrow',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplyPill extends StatelessWidget {
  const _ApplyPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.55)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Apply',
            style: TextStyle(
              fontFamily: 'Tomorrow',
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 16),
        ],
      ),
    );
  }
}

class _RetryPill extends StatelessWidget {
  const _RetryPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.refresh_rounded,
            color: AppColors.textSecondary,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            'Retry',
            style: TextStyle(
              fontFamily: 'Tomorrow',
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 16,
      width: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
