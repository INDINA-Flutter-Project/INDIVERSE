import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/game_preview.dart';
import '../../data.dart';
import '../game_detail/game_detail_screen.dart';
import '../game_detail/widgets/game_artwork.dart';
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
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        sliver: SliverList.list(
          children: [
            const _Header(),
            const SizedBox(height: 28),
            const Text(
              'Discover Saudi\nindie games.',
              style: TextStyle(
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
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),
            _FeaturedGame(
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
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                ),
                Text('See all', style: TextStyle(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
      SliverList.separated(
        itemCount: sampleGames.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GameCard(
            game: sampleGames[index],
            saved: wishlist.contains(sampleGames[index].title),
            onWishlist: () => onWishlist(sampleGames[index]),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.gamepad_rounded, color: Color(0xFF092117)),
      ),
      const SizedBox(width: 11),
      const Expanded(
        child: Text(
          'INDIVERSE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications_none_rounded),
      ),
    ],
  );
}

class _FeaturedGame extends StatelessWidget {
  const _FeaturedGame({
    required this.game,
    required this.saved,
    required this.onWishlist,
  });
  final GamePreview game;
  final bool saved;
  final VoidCallback onWishlist;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 310,
    child: Material(
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GameDetailsScreen(
              game: game,
              initiallySaved: saved,
              onWishlist: onWishlist,
            ),
          ),
        ),
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
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          game.genres.join('  •  '),
                          style: const TextStyle(
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
