class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String movieDetail = '/movie';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String watchlist = '/watchlist';
  static const String favorites = '/favorites';
  static const String ratedMovies = '/rated';
  static const String settings = '/settings';
  static const String personMovies = '/person';

  // Route parameters
  static const String movieIdParam = 'movieId';
  static const String personIdParam = 'personId';

  // Helper methods for route generation
  static String movieDetailRoute(int movieId) => '$movieDetail?$movieIdParam=$movieId';
  static String personMoviesRoute(int personId) => '$personMovies?$personIdParam=$personId';

  // All routes list for validation
  static const List<String> allRoutes = [
    splash,
    home,
    login,
    movieDetail,
    search,
    profile,
    watchlist,
    favorites,
    ratedMovies,
    settings,
    personMovies,
  ];
}