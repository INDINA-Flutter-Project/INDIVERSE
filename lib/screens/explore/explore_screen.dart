import 'package:flutter/material.dart';
import '../../models/game_preview.dart';
import '../../core/widget/empty_state.dart';
import '../../data.dart';
import '../home/widgets/game_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    required this.wishlist,
    required this.onWishlist,
  });
  final Set<String> wishlist;
  final ValueChanged<GamePreview> onWishlist;
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String query = '';
  String genre = 'All';

  @override
  Widget build(BuildContext context) {
    final games = sampleGames.where((game) {
      final q = query.toLowerCase();
      final matches =
          game.title.toLowerCase().contains(q) ||
          game.studio.toLowerCase().contains(q) ||
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
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
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
                          child: ChoiceChip(
                            label: Text(item),
                            selected: genre == item,
                            onSelected: (_) => setState(() => genre = item),
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
                    saved: widget.wishlist.contains(games[index].title),
                    onWishlist: () => widget.onWishlist(games[index]),
                  ),
                ),
        ),
      ],
    );
  }
}
