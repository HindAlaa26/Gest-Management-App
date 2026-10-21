import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/app_nav.dart';
import 'package:gest_managment_app/features/events/events_screen.dart';
import 'package:gest_managment_app/features/home/home_screen.dart';
import 'package:gest_managment_app/features/more/more_screen.dart';
import 'package:gest_managment_app/features/restaurants/restaurants_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    EventsScreen(),
    RestaurantsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppNav.tab,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: _screens,
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: index,
                onTap: (value) => AppNav.tab.value = value,
                selectedItemColor: AppColors.teal,
                unselectedItemColor: AppColors.muted,
                backgroundColor: AppColors.card,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 12,
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
                    icon: Icon(Icons.more_horiz),
                    label: 'More',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
