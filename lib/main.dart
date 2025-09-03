import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/hive_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/image_cache_service.dart';
import 'core/services/background_sync_service.dart';
import 'core/router/app_router.dart';
import 'shared/theme/app_theme_extension.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await HiveService.instance.init();
  await ConnectivityService.instance.initialize();
  await ImageCacheService.instance.initialize();
  await BackgroundSyncService.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.createRouter(ref);
    
    return MaterialApp.router(
      title: 'Flick Finder',
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
