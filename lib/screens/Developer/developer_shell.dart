import 'package:flutter/material.dart';

import 'developer_home_screen.dart';
import 'developer_profile_screen.dart';
import 'developer_creators_screen.dart';
import 'my_games_screen.dart';

class DeveloperShell extends StatefulWidget {
  const DeveloperShell({super.key});

  @override
  State<DeveloperShell> createState() => _DeveloperShellState();
}

class _DeveloperShellState extends State<DeveloperShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const screens = [
      DeveloperHomeScreen(),
      MyGamesScreen(),
      DeveloperCreatorsScreen(),
      DeveloperProfileScreen(),
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
