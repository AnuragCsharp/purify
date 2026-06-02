import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/screens/home_screen.dart';
import '../../cleaner/screens/cleaner_screen.dart';
import '../../ram/screens/ram_screen.dart';
import '../../gamification/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CleanerScreen(),
    RamScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.whatshot_outlined),
      activeIcon: Icon(Icons.whatshot_rounded),
      label: 'Clean',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bolt_outlined),
      activeIcon: Icon(Icons.bolt_rounded),
      label: 'Boost',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.emoji_events_outlined),
      activeIcon: Icon(Icons.emoji_events_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBar,
          border: Border(
              top: BorderSide(
                  color: AppColors.cardBorder.withValues(alpha: 0.6),
                  width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: _items,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}
