import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
import '../../service/database.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';

/// Owns player-level navigation and state shared between player tabs.
class PlayerShell extends StatefulWidget {
  const PlayerShell({super.key});

  @override
  State<PlayerShell> createState() => _PlayerShellState();
}

class _PlayerShellState extends State<PlayerShell> {
  final Database _database = Database();
  late Future<List<Game>> _gamesFuture;

  int selectedIndex = 0;
  Set<int> wishlist = {};

  @override
  void initState() {
    super.initState();
    _gamesFuture = _database.getAllGames();
  }

  void _retry() => setState(() {
    _gamesFuture = _database.getAllGames();
  });

  void toggleWishlist(Game game) => setState(() {
    wishlist.contains(game.id)
        ? wishlist.remove(game.id)
        : wishlist.add(game.id);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Game>>(
          future: _gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _GamesError(onRetry: _retry);
            }

            final games = snapshot.data ?? const <Game>[];
            final screens = [
              HomeScreen(
                games: games,
                wishlist: wishlist,
                onWishlist: toggleWishlist,
              ),
              ExploreScreen(
                games: games,
                wishlist: wishlist,
                onWishlist: toggleWishlist,
              ),
              WishlistScreen(
                games: games,
                wishlist: wishlist,
                onWishlist: toggleWishlist,
              ),
              const ProfileScreen(),
            ];

            return IndexedStack(index: selectedIndex, children: screens);
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => selectedIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _GamesError extends StatelessWidget {
  const _GamesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Unable to load games',
            style: TextStyle(fontFamily: 'Michroma', fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tomorrow',
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}
