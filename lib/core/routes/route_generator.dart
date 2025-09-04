import 'package:flick_finder/presentation/screens/main/main_tab_screen.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/cast.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/movie_detail/movie_detail_screen.dart';
import '../../presentation/screens/person_movies/person_movies_screen.dart';
import '../../presentation/screens/watchlist/watchlist_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/rated/rated_movies_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final uri = Uri.parse(settings.name ?? '/');
    final path = uri.path;
    final queryParams = uri.queryParameters;

    switch (path) {
      case AppRoutes.splash:
        // Handle deeplink movie ID from query parameters
        final movieId = queryParams[AppRoutes.movieIdParam];
        return MaterialPageRoute(
          builder: (_) => SplashScreen(deepLinkMovieId: movieId),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainTabScreen (),
          settings: settings,
        );

      case AppRoutes.login:
        final onLoginSuccess = args as VoidCallback?;
        return MaterialPageRoute(
          builder: (context) => LoginScreen(
            onLoginSuccess: onLoginSuccess ?? () {
              // Default behavior: do nothing, let the calling code handle navigation
            },
          ),
          settings: settings,
        );

      case AppRoutes.movieDetail:
        if (args is Movie) {
          return MaterialPageRoute(
            builder: (_) => MovieDetailScreen(movie: args),
            settings: settings,
          );
        } else {
          // Handle deeplink with movie ID in query params
          final movieIdStr = queryParams[AppRoutes.movieIdParam];
          if (movieIdStr != null) {
            final movieId = int.tryParse(movieIdStr);
            if (movieId != null) {
              // Create a placeholder movie for deeplink navigation
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
              return MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movie: movie),
                settings: settings,
              );
            }
          }
        }
        return _errorRoute('Movie not found');

      case AppRoutes.personMovies:
        if (args is Cast) {
          return MaterialPageRoute(
            builder: (_) => PersonMoviesScreen(person: args),
            settings: settings,
          );
        } else {
          // Handle deeplink with person ID in query params
          final personIdStr = queryParams[AppRoutes.personIdParam];
          if (personIdStr != null) {
            final personId = int.tryParse(personIdStr);
            if (personId != null) {
              // Create a placeholder cast member for deeplink navigation
              final person = Cast(
                id: personId,
                name: 'Loading...',
                character: '',
                profilePath: null,
                order: 0,
              );
              return MaterialPageRoute(
                builder: (_) => PersonMoviesScreen(person: person),
                settings: settings,
              );
            }
          }
        }
        return _errorRoute('Person not found');

      case AppRoutes.watchlist:
        return MaterialPageRoute(
          builder: (_) => const WatchlistScreen(),
          settings: settings,
        );

      case AppRoutes.favorites:
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
          settings: settings,
        );

      case AppRoutes.ratedMovies:
        return MaterialPageRoute(
          builder: (_) => const RatedMoviesScreen(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to home
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}