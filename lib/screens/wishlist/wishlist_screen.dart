import 'package:flutter/material.dart';
import '../../models/game_preview.dart';
import '../../core/widget/empty_state.dart';
import '../../data.dart';
import '../home/widgets/game_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({
    super.key,
    required this.wishlist,
    required this.onWishlist,
  });
  final Set<String> wishlist;
  final ValueChanged<GamePreview> onWishlist;

  @override
  Widget build(BuildContext context) {
    final games = sampleGames
        .where((game) => wishlist.contains(game.title))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 18),
          child: Text(
            'Wishlist',
            style: TextStyle(
              fontFamily: 'Michroma',
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: games.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Your wishlist is empty',
                  message:
                      'Save games you want to follow and they will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: games.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => GameCard(
                    game: games[index],
                    saved: true,
                    onWishlist: () => onWishlist(games[index]),
                  ),
                ),
        ),
      ],
    );
  }
}
