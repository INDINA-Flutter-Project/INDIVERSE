import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../core/widget/empty_state.dart';
import '../home/widgets/game_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({
    super.key,
    required this.games,
    required this.wishlist,
    required this.onWishlist,
  });
  final List<Game> games;
  final Set<int> wishlist;
  final ValueChanged<Game> onWishlist;

  @override
  Widget build(BuildContext context) {
    final savedGames = games
        .where((game) => wishlist.contains(game.id))
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
          child: savedGames.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Your wishlist is empty',
                  message:
                      'Save games you want to follow and they will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: savedGames.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => GameCard(
                    game: savedGames[index],
                    saved: true,
                    onWishlist: () => onWishlist(savedGames[index]),
                  ),
                ),
        ),
      ],
    );
  }
}
