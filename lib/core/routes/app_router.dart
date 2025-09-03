import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/cast.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
import '../../presentation/screens/person_movies/person_movies_screen.dart';
import '../../presentation/screens/watchlist/watchlist_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/rated/rated_movies_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../main.dart';
import '../services/deeplink_service.dart';
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    navigatorKey: DeepLinkService.navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      
      // Show splash while loading
      if (isLoading) {
        return '/';
      }
      
      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && state.matchedLocation != '/login') {
        // Store the intended destination for after login
        final movieId = state.uri.queryParameters['movieId'];
        if (movieId != null) {
          return '/login?redirect=${Uri.encodeComponent('/movie/$movieId')}';
        }
        return '/login';
      }
      
      // If authenticated and on login page, redirect to home
      if (isAuthenticated && state.matchedLocation == '/login') {
        final redirect = state.uri.queryParameters['redirect'];
        return redirect != null ? Uri.decodeComponent(redirect) : '/home';
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Splash route
      GoRoute(
        path: '/',
        builder: (context, state) {
          final movieId = state.uri.queryParameters['movieId'];
          return SplashScreen(deepLinkMovieId: movieId);
        },
      ),
      
      // Login route
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return LoginScreen(
            onLoginSuccess: () {
              final redirect = state.uri.queryParameters['redirect'];
              if (redirect != null) {
                context.go(Uri.decodeComponent(redirect));
              } else {
                context.go('/home');
              }
            },
          );
        },
      ),
      
      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreenWrapper(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreenWrapper(),
          ),
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverScreenWrapper(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // Profile sub-routes - these will be full screen but maintain navigation stack
              GoRoute(
                path: 'watchlist',
                builder: (context, state) => const WatchlistScreen(),
              ),
              GoRoute(
                path: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: 'rated',
                builder: (context, state) => const RatedMoviesScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Standalone routes (outside shell for full screen)
      
      // Movie detail route (outside shell for full screen)
      GoRoute(
        path: '/movie/:movieId',
        builder: (context, state) {
          final movieIdStr = state.pathParameters['movieId']!;
          final movieId = int.parse(movieIdStr);
          
          // Create a placeholder movie for the screen
          final movie = Movie(
            id: movieId,
            title: 'Loading...',
            description: '',
            posterPath: null,
            backdropPath: null,
            releaseDate: DateTime.now(),
            rating: 0.0,
            voteCount: 0,
            genreIds: [],
          );
          
          return MovieDetailScreen(movie: movie);
        },
      ),
      
      // Person movies route
      GoRoute(
        path: '/person/:personId',
        builder: (context, state) {
          final personIdStr = state.pathParameters['personId']!;
          final personId = int.parse(personIdStr);
          
          // Create a placeholder person for the screen
          final person = Cast(
            id: personId,
            name: 'Loading...',
            character: '',
            profilePath: null,
            order: 0,
          );
          
          return PersonMoviesScreen(person: person);
        },
      ),
    ],
    
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Wrapper classes for the main screens
class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      onNavigateToSearch: () {
        context.go('/search');
      },
    );
  }
}

class SearchScreenWrapper extends StatelessWidget {
  const SearchScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchScreen();
  }
}

class DiscoverScreenWrapper extends StatelessWidget {
  const DiscoverScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Return a placeholder for now - you can implement discover functionality later
    return const Center(
      child: Text(
        'Discover Screen\nComing Soon!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}