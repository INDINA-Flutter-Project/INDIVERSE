import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
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

  @override
  void initState() {
    super.initState();
    _loadInterestState();
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

  Future<void> _toggleInterest() async {
    if (_playtestBusy) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _playtestBusy = true);
    try {
      if (_interestState == _InterestState.interested) {
        await PlaytestInterestService().removeInterest(
          gameId: widget.game.id,
          playerId: userId,
        );
        if (!mounted) return;
        setState(() => _interestState = _InterestState.notInterested);
      } else {
        await PlaytestInterestService().registerInterest(
          gameId: widget.game.id,
        );
        if (!mounted) return;
        setState(() => _interestState = _InterestState.interested);
      }
    } catch (e, st) {
      debugPrint('playtest interest toggle failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
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
            actions: [
              IconButton(
                onPressed: () {
                  widget.onWishlist();
                  setState(() => saved = !saved);
                },
                icon: Icon(
                  saved
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
                      fit: BoxFit.cover,
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
                  child: const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(
                        Icons.celebration_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      'Playable demo showcase',
                      style: TextStyle(fontFamily: 'Michroma'),
                    ),
                    subtitle: Text(
                      '18 September · Riyadh',
                      style: TextStyle(fontFamily: 'Tomorrow'),
                    ),
                    trailing: Text(
                      'UPCOMING',
                      style: TextStyle(
                        fontFamily: 'Tomorrow',
                        color: AppColors.primary,
                        fontSize: 9,
                      ),
                    ),
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
                            onPressed: () => UrlLauncherService.openExternalUrl(
                              websiteUrl,
                            ),
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
                if (isUpcoming) ...[
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: switch (_interestState) {
                      _InterestState.loading => FilledButton.icon(
                          onPressed: null,
                          icon: const _Spinner(),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text('Checking interest…'),
                          ),
                        ),
                      _InterestState.error => OutlinedButton.icon(
                          onPressed: _loadInterestState,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text('Could not check interest — Tap to retry'),
                          ),
                        ),
                      _InterestState.notInterested => FilledButton.icon(
                          onPressed: _playtestBusy ? null : _toggleInterest,
                          icon: _playtestBusy
                              ? const _Spinner()
                              : const Icon(Icons.emoji_people_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text("I'm Interested in Playtesting"),
                          ),
                        ),
                      _InterestState.interested => OutlinedButton.icon(
                          onPressed: _playtestBusy ? null : _toggleInterest,
                          icon: _playtestBusy
                              ? const _Spinner()
                              : const Icon(Icons.check_circle_outline_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text('Interested ✓'),
                          ),
                        ),
                    },
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
