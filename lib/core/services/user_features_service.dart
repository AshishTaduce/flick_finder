import '../services/auth_service.dart';
import '../services/tmdb_auth_service.dart';

class UserFeaturesService {
  static UserFeaturesService? _instance;
  static UserFeaturesService get instance => _instance ??= UserFeaturesService._();
  UserFeaturesService._();

  /// Check if user can access premium features (not a guest)
  Future<bool> canAccessPremiumFeatures() async {
    final isAuthenticated = await AuthService.instance.isAuthenticated();
    final isGuest = await AuthService.instance.isGuest();
    return isAuthenticated && !isGuest;
  }

  /// Get movie account states (favorite, watchlist, rated)
  Future<Map<String, dynamic>?> getMovieAccountStates(int movieId) async {
    if (!await canAccessPremiumFeatures()) return null;
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      if (sessionId == null) return null;
      
      return await TmdbAuthService.instance.getMovieAccountStates(
        movieId: movieId,
        sessionId: sessionId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Add or remove movie from watchlist
  Future<bool> toggleWatchlist(int movieId, bool addToWatchlist) async {
    if (!await canAccessPremiumFeatures()) {
      throw Exception('Please login with your TMDB account to use watchlist');
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      final accountId = await AuthService.instance.getAccountId();
      
      if (sessionId == null || accountId == null) {
        throw Exception('Authentication required');
      }
      
      return await TmdbAuthService.instance.addToWatchlist(
        accountId: int.parse(accountId),
        movieId: movieId,
        watchlist: addToWatchlist,
        sessionId: sessionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Add or remove movie from favorites
  Future<bool> toggleFavorite(int movieId, bool addToFavorites) async {
    if (!await canAccessPremiumFeatures()) {
      throw Exception('Please login with your TMDB account to use favorites');
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      final accountId = await AuthService.instance.getAccountId();
      
      if (sessionId == null || accountId == null) {
        throw Exception('Authentication required');
      }
      
      return await TmdbAuthService.instance.addToFavorites(
        accountId: int.parse(accountId),
        movieId: movieId,
        favorite: addToFavorites,
        sessionId: sessionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Rate a movie
  Future<bool> rateMovie(int movieId, double rating) async {
    if (!await canAccessPremiumFeatures()) {
      throw Exception('Please login with your TMDB account to rate movies');
    }
    
    if (rating < 0.5 || rating > 10.0) {
      throw Exception('Rating must be between 0.5 and 10.0');
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      
      if (sessionId == null) {
        throw Exception('Authentication required');
      }
      
      return await TmdbAuthService.instance.rateMovie(
        movieId: movieId,
        rating: rating,
        sessionId: sessionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's watchlist
  Future<List<dynamic>> getWatchlist({int page = 1}) async {
    if (!await canAccessPremiumFeatures()) {
      return [];
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      final accountId = await AuthService.instance.getAccountId();
      
      if (sessionId == null || accountId == null) {
        return [];
      }
      
      return await TmdbAuthService.instance.getWatchlist(
        accountId: int.parse(accountId),
        sessionId: sessionId,
        page: page,
      );
    } catch (e) {
      return [];
    }
  }

  /// Get user's favorites
  Future<List<dynamic>> getFavorites({int page = 1}) async {
    if (!await canAccessPremiumFeatures()) {
      return [];
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      final accountId = await AuthService.instance.getAccountId();
      
      if (sessionId == null || accountId == null) {
        return [];
      }
      
      return await TmdbAuthService.instance.getFavorites(
        accountId: int.parse(accountId),
        sessionId: sessionId,
        page: page,
      );
    } catch (e) {
      return [];
    }
  }

  /// Get user's rated movies
  Future<List<dynamic>> getRatedMovies({int page = 1}) async {
    if (!await canAccessPremiumFeatures()) {
      return [];
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      final accountId = await AuthService.instance.getAccountId();
      
      if (sessionId == null || accountId == null) {
        return [];
      }
      
      return await TmdbAuthService.instance.getRatedMovies(
        accountId: int.parse(accountId),
        sessionId: sessionId,
        page: page,
      );
    } catch (e) {
      return [];
    }
  }
}