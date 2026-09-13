import 'package:flutter/material.dart';

import '../../core/models/game_preview.dart';
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
  int selectedIndex = 0;
  final wishlist = <String>{};

  void toggleWishlist(GamePreview game) => setState(() {
    wishlist.contains(game.title)
        ? wishlist.remove(game.title)
        : wishlist.add(game.title);
  });

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(wishlist: wishlist, onWishlist: toggleWishlist),
      ExploreScreen(wishlist: wishlist, onWishlist: toggleWishlist),
      WishlistScreen(wishlist: wishlist, onWishlist: toggleWishlist),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: selectedIndex, children: screens),
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
