import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
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

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late bool saved = widget.initiallySaved;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final steamUrl = game.steamUrl?.trim();
    final websiteUrl = game.extraLinks?.trim();
    final hasSteam = steamUrl != null && steamUrl.isNotEmpty;
    final hasWebsite = websiteUrl != null && websiteUrl.isNotEmpty;
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
