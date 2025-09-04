import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Handle app launch from deep link
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // Handle deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');
    _navigateFromDeepLink(uri);
  }

  /// Navigate based on deep link URI using GoRouter
  void _navigateFromDeepLink(Uri uri) {
    final segments = uri.pathSegments;

    if (segments.isNotEmpty && segments[0] == 'movie' && segments.length > 1) {
      final movieIdStr = segments[1];
      final movieId = int.tryParse(movieIdStr);
      
      if (movieId != null) {
        // Use GoRouter to navigate to the movie page
        // GoRouter will handle authentication redirects automatically
        final router = GoRouter.of(navigatorKey.currentContext!);
        router.go('/movie/$movieId');
      }
    }
  }

  // Keep a reference to the router's navigator key
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Generate shareable deep link for movie
  static String generateMovieDeepLink(int movieId) {
    return 'flickfinder://movie/$movieId';
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}