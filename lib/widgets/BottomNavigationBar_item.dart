import 'package:flutter/material.dart';

import '../screens/events_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/home_screen.dart';
import '../screens/restaurants_screen.dart';
import '../utils/theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    EventsScreen(),
    RestaurantsScreen(),
    FeedbackScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (value) => setState(() => index = value),
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.muted,
          backgroundColor: AppColors.card,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              label: 'Dining',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_outlined),
              label: 'Feedback',
            ),
          ],
        ),
      ),
    );
  }
}
