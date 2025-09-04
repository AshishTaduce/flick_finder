import 'package:flick_finder/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/hive_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/background_sync_service.dart';
import 'core/services/deeplink_service.dart';
import 'core/routes/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'shared/theme/app_theme.dart';

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


