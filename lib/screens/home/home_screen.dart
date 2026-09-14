import 'package:flutter/material.dart';
import 'package:indina/screens/home/widgets/featured_game.dart';
import 'package:indina/screens/home/widgets/header.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_preview.dart';
import '../../data.dart';

import 'widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.wishlist,
    required this.onWishlist,
  });

  final Set<String> wishlist;
  final ValueChanged<GamePreview> onWishlist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                game: sampleGames.first,
                saved: wishlist.contains(sampleGames.first.title),
                onWishlist: () => onWishlist(sampleGames.first),
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
                  Text('See all', style: TextStyle(color: AppColors.primary)),
                ],
              ),

              const SizedBox(height: 14),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sampleGames.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final game = sampleGames[index];

                  return GameCard(
                    game: game,
                    saved: wishlist.contains(game.title),
                    onWishlist: () => onWishlist(game),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
