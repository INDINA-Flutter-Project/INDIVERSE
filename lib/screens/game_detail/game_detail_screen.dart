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
                      const ListTile(
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
                      if (isUpcoming) ...[
                        const Divider(color: AppColors.border, height: 24),
                        switch (_interestState) {
                          _InterestState.loading => const _ActivityRow(
                            title: 'Playtesting',
                            subtitle: 'Checking your interest…',
                            trailing: _Spinner(),
                          ),
                          _InterestState.error => _ActivityRow(
                            title: 'Playtesting',
                            subtitle: 'Could not check interest · Tap to retry',
                            trailing: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.textSecondary,
                            ),
                            onTap: _loadInterestState,
                          ),
                          _InterestState.notInterested => _ActivityRow(
                            title: 'Playtesting',
                            subtitle: 'Interested in testing this game',
                            trailing: _playtestBusy
                                ? const _Spinner()
                                : const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                            onTap: _playtestBusy ? null : _toggleInterest,
                          ),
                          _InterestState.interested => _ActivityRow(
                            title: 'Playtesting',
                            subtitle: "You're interested in playtesting",
                            trailing: _playtestBusy
                                ? const _Spinner()
                                : const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                  ),
                            onTap: _playtestBusy ? null : _toggleInterest,
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

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: const CircleAvatar(
        backgroundColor: AppColors.primaryContainer,
        child: Icon(Icons.emoji_people_outlined, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontFamily: 'Michroma')),
      subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Tomorrow')),
      trailing: trailing,
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
