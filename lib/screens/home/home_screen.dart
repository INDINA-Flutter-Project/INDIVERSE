import 'package:flutter/material.dart';
import 'package:indina/screens/home/widgets/header.dart';
import 'package:indina/screens/home/widgets/upcoming_games_carousel.dart';

import '../../core/constants/app_colors.dart';
import '../../models/game.dart';

import 'widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.games,
    required this.wishlist,
    required this.onWishlist,
    required this.preferredGenres,
  });

  final List<Game> games;
  final Set<int> wishlist;
  final ValueChanged<Game> onWishlist;

  /// The signed-in player's saved genre preferences, as loaded by
  /// PlayerShell from Database.getUserPreferences. Empty when the player
  /// hasn't saved preferences yet (or preferences failed to load).
  final List<String> preferredGenres;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const _GamesEmpty();
    }

    final upcomingGames = games
        .where((game) => game.status?.trim().toLowerCase() == 'upcoming')
        .toList();

    final normalizedPreferences = preferredGenres
        .map((genre) => genre.trim().toLowerCase())
        .where((genre) => genre.isNotEmpty)
        .toSet();

    final matchingGames = games.where((game) {
      return game.genres.any(
        (genre) => normalizedPreferences.contains(genre.trim().toLowerCase()),
      );
    }).toList();

    final forYouGames = preferredGenres.isEmpty ? games : matchingGames;

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
          if (upcomingGames.isNotEmpty) ...[
            UpcomingGamesCarousel(
              games: upcomingGames,
              wishlist: wishlist,
              onWishlist: onWishlist,
            ),
            const SizedBox(height: 30),
          ],
          const Text(
            'For you',
            style: TextStyle(
              fontFamily: 'Michroma',
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (forYouGames.isEmpty)
            const _ForYouEmpty()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: forYouGames.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final game = forYouGames[index];

                return GameCard(
                  game: game,
                  saved: wishlist.contains(game.id),
                  onWishlist: () => onWishlist(game),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ForYouEmpty extends StatelessWidget {
  const _ForYouEmpty();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: const Column(
      children: [
        Icon(Icons.tune_rounded, color: AppColors.primary),
        SizedBox(height: 10),
        Text(
          'No games match your preferences yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Tomorrow',
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
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
