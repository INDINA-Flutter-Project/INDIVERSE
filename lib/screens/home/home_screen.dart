import 'package:flutter/material.dart';
import 'package:indina/screens/home/widgets/featured_game.dart';
import 'package:indina/screens/home/widgets/header.dart';

import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
import '../../models/game_preview.dart';
import '../../service/database.dart';

import 'widgets/game_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.wishlist,
    required this.onWishlist,
  });

  final Set<String> wishlist;
  final ValueChanged<GamePreview> onWishlist;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _artworkColors = [
    [Color(0xFFB96832), Color(0xFF3B1938)],
    [Color(0xFF2856A8), Color(0xFF8D2CA1)],
    [Color(0xFF2F7955), Color(0xFFC49540)],
  ];

  final Database _database = Database();
  late Future<List<Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _database.getAllGames();
  }

  void _retry() => setState(() {
    _gamesFuture = _database.getAllGames();
  });

  GamePreview _toPreview(Game game) {
    return GamePreview(
      title: game.name,
      studio: game.developer ?? game.publisher ?? 'Independent studio',
      description:
          game.shortDescription ?? game.description ?? 'Details coming soon.',
      genres: game.genres,
      platforms: const [],
      status: game.status ?? 'Available',
      colors: _artworkColors[game.id.abs() % _artworkColors.length],
      icon: Icons.sports_esports_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Game>>(
          future: _gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _GamesError(onRetry: _retry);
            }

            final games = snapshot.data ?? const <Game>[];
            if (games.isEmpty) {
              return const _GamesEmpty();
            }

            final previews = games.map(_toPreview).toList(growable: false);
            final featuredGame = previews.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Header(),
                  const SizedBox(height: 28),
                  const Text(
                    'Discover Saudi\nindie games.',
                    style: TextStyle(
                      fontFamily: 'Michroma',
                      fontSize: 34,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Original worlds. Local talent. Your next favorite game.',
                    style: TextStyle(
                      fontFamily: 'Tomorrow',
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 26),
                  FeaturedGame(
                    game: featuredGame,
                    saved: widget.wishlist.contains(featuredGame.title),
                    onWishlist: () => widget.onWishlist(featuredGame),
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'For you',
                          style: TextStyle(
                            fontFamily: 'Michroma',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'See all',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: previews.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final game = previews[index];

                      return GameCard(
                        game: game,
                        saved: widget.wishlist.contains(game.title),
                        onWishlist: () => widget.onWishlist(game),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GamesError extends StatelessWidget {
  const _GamesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Unable to load games',
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
    ),
  );
}

class _GamesEmpty extends StatelessWidget {
  const _GamesEmpty();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'No games are available yet.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Tomorrow',
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
    ),
  );
}
