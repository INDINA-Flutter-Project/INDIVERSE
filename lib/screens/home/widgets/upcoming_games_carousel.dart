import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:indina/core/constants/app_colors.dart';
import 'package:indina/models/game.dart';
import 'package:indina/screens/game_detail/game_detail_screen.dart';

class UpcomingGamesCarousel extends StatefulWidget {
  const UpcomingGamesCarousel({
    super.key,
    required this.games,
    required this.wishlist,
    required this.onWishlist,
  });

  /// Already filtered to upcoming-only games by the caller.
  final List<Game> games;
  final Set<int> wishlist;
  final ValueChanged<Game> onWishlist;

  @override
  State<UpcomingGamesCarousel> createState() => _UpcomingGamesCarouselState();
}

class _UpcomingGamesCarouselState extends State<UpcomingGamesCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final games = widget.games;
    final showMultiple = games.length > 1;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: games.length,
          itemBuilder: (context, index, realIndex) {
            final game = games[index];
            return _UpcomingHeroCard(
              game: game,
              saved: widget.wishlist.contains(game.id),
              onWishlist: () => widget.onWishlist(game),
            );
          },
          options: CarouselOptions(
            height: 280,
            viewportFraction: 1,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOut,
            autoPlayInterval: const Duration(seconds: 6),
            enableInfiniteScroll: showMultiple,
            onPageChanged: (index, reason) =>
                setState(() => _currentIndex = index),
          ),
        ),
        if (showMultiple) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < games.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _currentIndex ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _currentIndex
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _UpcomingHeroCard extends StatelessWidget {
  const _UpcomingHeroCard({
    required this.game,
    required this.saved,
    required this.onWishlist,
  });

  final Game game;
  final bool saved;
  final VoidCallback onWishlist;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameDetailsScreen(
                game: game,
                initiallySaved: saved,
                onWishlist: onWishlist,
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(right: 7),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.surface),
              if (game.coverImage != null)
                Image.network(
                  game.coverImage!,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE6070C0B)],
                  ),
                ),
              ),

              Positioned(
                left: 20,
                right: 18,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UPCOMING',
                      style: TextStyle(
                        fontFamily: 'Tomorrow',
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Text(
                    //   game.name,
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: const TextStyle(
                    //     fontFamily: 'Michroma',
                    //     fontSize: 25,
                    //     fontWeight: FontWeight.w800,
                    //   ),
                    // ),
                    if (game.genres.isNotEmpty)
                      Text(
                        game.genres.join('  •  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Tomorrow',
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
