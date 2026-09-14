import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:indina/core/constants/app_colors.dart';
import 'package:indina/models/game_preview.dart';
import 'package:indina/screens/game_detail/game_detail_screen.dart';
import 'package:indina/screens/game_detail/widgets/game_artwork.dart';

class FeaturedGame extends StatelessWidget {
  const FeaturedGame({
    super.key,
    required this.game,
    required this.saved,
    required this.onWishlist,
  });

  final GamePreview game;
  final bool saved;
  final VoidCallback onWishlist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310,
      child: Material(
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              GameArtwork(
                game: game,
                width: double.infinity,
                height: 310,
                radius: 0,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FEATURED',
                            style: TextStyle(
                              fontFamily: 'Tomorrow',
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            game.title,
                            style: const TextStyle(
                              fontFamily: 'Michroma',
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          Text(
                            game.genres.join('  •  '),
                            style: const TextStyle(
                              fontFamily: 'Tomorrow',
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton.filledTonal(
                      onPressed: onWishlist,
                      icon: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
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
