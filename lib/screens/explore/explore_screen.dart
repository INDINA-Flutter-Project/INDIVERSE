import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widget/empty_state.dart';
import '../../core/widget/glass_action.dart';
import '../../models/game.dart';
import '../home/widgets/game_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.games,
    required this.wishlist,
    required this.onWishlist,
  });
  final List<Game> games;
  final Set<int> wishlist;
  final ValueChanged<Game> onWishlist;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String query = '';
  String genre = 'All';

  @override
  Widget build(BuildContext context) {
    final games = widget.games.where((game) {
      final q = query.toLowerCase();
      final matches =
          game.name.toLowerCase().contains(q) ||
          (game.developer ?? game.publisher ?? '').toLowerCase().contains(q) ||
          game.genres.any((value) => value.toLowerCase().contains(q));
      return matches && (genre == 'All' || game.genres.contains(genre));
    }).toList();
    const filters = ['All', 'Action', 'Adventure', 'Simulation', 'Story Rich'];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore',
                style: TextStyle(
                  fontFamily: 'Michroma',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search games, studios, genres',
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: genre == item
                              ? GlassAction(
                                  onPressed: () => setState(() => genre = item),
                                  label: item,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 9,
                                  ),
                                )
                              : ChoiceChip(
                                  label: Text(item),
                                  selected: false,
                                  labelStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => genre = item),
                                ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: games.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No games found',
                  message: 'Try another title, studio, or genre.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: games.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => GameCard(
                    game: games[index],
                    saved: widget.wishlist.contains(games[index].id),
                    onWishlist: () => widget.onWishlist(games[index]),
                  ),
                ),
        ),
      ],
    );
  }
}
