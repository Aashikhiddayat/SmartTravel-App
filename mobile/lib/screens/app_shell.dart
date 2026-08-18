import 'package:flutter/material.dart';

import '../providers/app_controller.dart';
import '../widgets/status_banner.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'memories_screen.dart';
import 'profile_screen.dart';
import 'trips_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});
  final AppController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [HomeScreen(controller: widget.controller), TripsScreen(controller: widget.controller), ExploreScreen(controller: widget.controller), MemoriesScreen(controller: widget.controller), ProfileScreen(controller: widget.controller)];
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          if (widget.controller.demoMode) const StatusBanner(message: 'DEMO MODE — places, alerts and safety zones are illustrative, not live.'),
          if (widget.controller.offlineBanner) const StatusBanner(message: 'Offline mode — showing saved trip information; live information may be outdated.', color: Color(0xFF715B00)),
          Expanded(child: IndexedStack(index: _index, children: pages)),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.luggage_outlined), selectedIcon: Icon(Icons.luggage), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: 'Memories'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

