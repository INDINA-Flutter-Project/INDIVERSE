import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../models/game.dart';
import '../../service/database.dart';
import 'developer_home_screen.dart';
import 'developer_profile_screen.dart';
import 'developer_creators_screen.dart';
import 'my_games_screen.dart';

/// Owns developer-level navigation and the signed-in developer's real games.
class DeveloperShell extends StatefulWidget {
  const DeveloperShell({super.key});

  @override
  State<DeveloperShell> createState() => _DeveloperShellState();
}

class _DeveloperShellState extends State<DeveloperShell> {
  final Database _database = Database();
  late Future<List<Game>> _gamesFuture;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _loadGames();
  }

  Future<List<Game>> _loadGames() {
    final developerId = Supabase.instance.client.auth.currentUser?.id;
    if (developerId == null) return Future.value(const <Game>[]);
    return _database.getGamesByDeveloper(developerId);
  }

  void _retry() => setState(() {
    _gamesFuture = _loadGames();
  });

  Future<void> _reloadGames() async {
    final future = _loadGames();
    setState(() {
      _gamesFuture = future;
    });
    await future;
  }

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
              DeveloperHomeScreen(games: games, onGamesChanged: _reloadGames),
              MyGamesScreen(games: games, onGamesChanged: _reloadGames),
              const DeveloperCreatorsScreen(),
              const DeveloperProfileScreen(),
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
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports_rounded),
            label: 'My Games',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Creators',
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
            'Unable to load your games',
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
