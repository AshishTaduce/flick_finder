import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/movie.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/movie_detail_provider.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/watchlist/watchlist_screen.dart';
import '../../presentation/screens/rated/rated_movies_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/person_movies/person_movies_screen.dart';
import '../../domain/entities/cast.dart';
import '../../shared/widgets/network_status_indicator.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: (context, state) {
        final authState = ref.read(authProvider);
        final isOnSplash = state.matchedLocation == '/';
        final isOnLogin = state.matchedLocation == '/login';
        final isOnMovieDetail = state.matchedLocation.startsWith('/movie/');
        
        // If on splash, let it handle the flow
        if (isOnSplash) return null;
        
        // If not authenticated and not on login, redirect to login
        if (!authState.isAuthenticated && !isOnLogin) {
          // Store the intended destination for after login
          if (isOnMovieDetail) {
            return '/login?redirect=${Uri.encodeComponent(state.matchedLocation)}';
          }
          return '/login';
        }
        
        // If authenticated and on login, redirect to home
        if (authState.isAuthenticated && isOnLogin) {
          final redirect = state.uri.queryParameters['redirect'];
          return redirect != null ? Uri.decodeComponent(redirect) : '/home';
        }
        
        return null;
      },
      routes: [
        // Splash route
        GoRoute(
          path: '/',
          builder: (context, state) {
            final movieId = state.uri.queryParameters['movie'];
            return SplashScreen(
              movieId: movieId,
              onInitComplete: () {
                final authState = ref.read(authProvider);
                if (movieId != null) {
                  // Deep link to movie
                  if (authState.isAuthenticated) {
                    context.go('/movie/$movieId');
                  } else {
                    context.go('/login?redirect=${Uri.encodeComponent('/movie/$movieId')}');
                  }
                } else {
                  // Normal app flow
                  if (authState.isAuthenticated) {
                    context.go('/home');
                  } else {
                    context.go('/login');
                  }
                }
              },
            );
          },
        ),
        
        // Login route
        GoRoute(
          path: '/login',
          builder: (context, state) {
            final redirect = state.uri.queryParameters['redirect'];
            return LoginScreen(
              onLoginSuccess: () {
                if (redirect != null) {
                  context.go(Uri.decodeComponent(redirect));
                } else {
                  context.go('/home');
                }
              },
            );
          },
        ),
        
        // Main app shell
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainAppShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => HomeScreen(
                onNavigateToSearch: () => context.go('/search'),
              ),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/watchlist',
              builder: (context, state) => const WatchlistScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        
        // Movie detail route (outside shell for full screen)
        GoRoute(
          path: '/movie/:id',
          builder: (context, state) {
            final movieId = int.tryParse(state.pathParameters['id'] ?? '');
            if (movieId == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid movie ID')),
              );
            }
            
            return Consumer(
              builder: (context, ref, child) {
                final movieDetailState = ref.watch(movieDetailProvider(movieId));
                
                // If we have movie detail, use it
                if (movieDetailState.movieDetail != null) {
                  final movie = Movie(
                    id: movieDetailState.movieDetail!.id,
                    title: movieDetailState.movieDetail!.title,
                    description: movieDetailState.movieDetail!.description,
                    posterPath: movieDetailState.movieDetail!.posterPath,
                    backdropPath: movieDetailState.movieDetail!.backdropPath,
                    releaseDate: movieDetailState.movieDetail!.releaseDate,
                    rating: movieDetailState.movieDetail!.rating,
                    voteCount: movieDetailState.movieDetail!.voteCount,
                    genreIds: [], // Will be populated from genres
                  );
                  return MovieDetailScreen(movie: movie);
                }
                
                // If loading, show loading screen
                if (movieDetailState.isLoadingDetail) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                
                // If error, show error screen
                if (movieDetailState.errorDetail != null) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Error')),
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64),
                          const SizedBox(height: 16),
                          Text('Movie not found: ${movieDetailState.errorDetail}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/home'),
                            child: const Text('Go Home'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Create a minimal movie object for the screen to load
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
            );
          },
        ),
        
        // Person movies route
        GoRoute(
          path: '/person/:id',
          builder: (context, state) {
            final personId = int.tryParse(state.pathParameters['id'] ?? '');
            if (personId == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid person ID')),
              );
            }
            
            // Create a minimal person object for navigation
            return PersonMoviesScreen(
              person: Cast(
                id: personId,
                name: 'Loading...',
                character: '',
                profilePath: null,
                order: 0,
              ),
            );
          },
        ),
        
        // Additional full-screen routes
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/rated',
          builder: (context, state) => const RatedMoviesScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),

      ],
    );
  }
}

class MainAppShell extends StatefulWidget {
  final Widget child;

  const MainAppShell({super.key, required this.child});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _currentIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/watchlist');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current route
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) {
      _currentIndex = 0;
    } else if (location.startsWith('/search')) {
      _currentIndex = 1;
    } else if (location.startsWith('/watchlist')) {
      _currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      _currentIndex = 3;
    }

    return Scaffold(
      body: NetworkStatusBanner(child: widget.child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.playlist_play_outlined),
            selectedIcon: Icon(Icons.playlist_play),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}