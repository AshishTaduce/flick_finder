import 'dart:ui';

import 'package:flick_finder/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/services/hive_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/background_sync_service.dart';
import 'core/services/deeplink_service.dart';
import 'core/routes/app_router.dart';
import 'presentation/widgets/nav_bar_item.dart';
import 'presentation/providers/auth_provider.dart';

import 'shared/theme/app_insets.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/network_status_indicator.dart';

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await HiveService.instance.init();
  await ConnectivityService.instance.initialize();
  await ImageCacheService.instance.initialize();
  await BackgroundSyncService.instance.initialize();

  // Initialize deep link service
  await DeepLinkService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    // Initialize auth listener to handle state changes
    ref.watch(authListenerProvider);

    return MaterialApp.router(
      title: 'Movie Discovery',
      theme: AppTheme.lightTheme.copyWith(
        extensions: [MovieThemeExtension.light],
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        extensions: [MovieThemeExtension.dark],
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    switch (location) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/discover':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/discover');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: NetworkStatusBanner(
        child: Padding(
          padding: EdgeInsets.only(bottom: AppInsets.xxl),
          child: widget.child,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      // Navigation Bar
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(),
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
                  Expanded(
                    child: NavBarItem(
                      icon: Icons.home,
                      label: "Home",
                      isActive: selectedIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                  ),
                  Expanded(
                    child: NavBarItem(
                      icon: Icons.search,
                      label: "Search",
                      isActive: selectedIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                  ),
                  Expanded(
                    child: NavBarItem(
                      icon: Icons.person,
                      label: "Profile",
                      isActive: selectedIndex == 3,
                      onTap: () => _onItemTapped(3),
                    ),
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
