import 'package:flutter/material.dart';
import '../regional/regional_feed_screen.dart';
import '../business/business_feed_screen.dart';
import '../devotional/devotional_feed_screen.dart';
import '../settings/settings_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    RegionalFeedScreen(),
    BusinessFeedScreen(),
    DevotionalFeedScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Regional'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Business'),
          BottomNavigationBarItem(
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings'),
              icon: Icon(Icons.temple_hindu),
              label: 'Devotional'),
        ],
      ),
    );
  }
}
