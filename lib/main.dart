import 'dart:ui';

import 'package:flick_finder/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/widgets/nav_bar_item.dart';
import 'presentation/widgets/auth_wrapper.dart';
import 'shared/theme/app_insets.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Discovery',
      theme: AppTheme.lightTheme.copyWith(
        extensions: [MovieThemeExtension.light],
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        extensions: [MovieThemeExtension.dark],
      ),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(child: MainScreen()),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigateToSearch: () => _navigateToTab(1)),
      const SearchScreen(),
      const Center(child: Text('Discover')), // Placeholder
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: AppInsets.xxl),
        child: IndexedStack(index: _currentIndex, children: screens),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      // Navigation Bar
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(
          // horizontal: AppInsets.lg,
          // vertical: AppInsets.md,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppInsets.md),
            topRight: Radius.circular(AppInsets.md),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).surfaceVariant.withAlpha(150),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withAlpha(50),
                  width: 01,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppInsets.sm,
                vertical: AppInsets.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavBarItem(
                    icon: Icons.home,
                    label: "Home",
                    isActive: _currentIndex == 0,
                    onTap: () => _navigateToTab(0),
                  ),
                  NavBarItem(
                    icon: Icons.search,
                    label: "Search",
                    isActive: _currentIndex == 1,
                    onTap: () => _navigateToTab(1),
                  ),
                  NavBarItem(
                    icon: Icons.playlist_play,
                    label: "Watch List",
                    isActive: _currentIndex == 2,
                    onTap: () => _navigateToTab(2),
                  ),
                  NavBarItem(
                    icon: Icons.person,
                    label: "Profile",
                    isActive: _currentIndex == 3,
                    onTap: () => _navigateToTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
