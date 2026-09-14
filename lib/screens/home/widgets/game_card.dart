import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/game_preview.dart';
import '../../game_detail/game_detail_screen.dart';
import '../../game_detail/widgets/game_artwork.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.saved,
    required this.onWishlist,
  });
  final GamePreview game;
  final bool saved;
  final VoidCallback onWishlist;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            GameArtwork(game: game, width: 94, height: 112, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.status.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Tomorrow',
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    game.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Michroma',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.studio,
                    style: const TextStyle(
                      fontFamily: 'Tomorrow',
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    game.genres.take(2).join('  •  '),
                    style: const TextStyle(
                      fontFamily: 'Tomorrow',
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onWishlist,
              icon: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: saved ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
