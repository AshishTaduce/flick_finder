import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class TmdbAuthService {
  static TmdbAuthService? _instance;
  static TmdbAuthService get instance => _instance ??= TmdbAuthService._();
  TmdbAuthService._();

  final Dio _dio = DioClient.instance;

  /// Step 1: Create a request token
  Future<String> createRequestToken() async {
    try {
      final response = await _dio.get(ApiConstants.createRequestToken);
      
      if (response.data['success'] == true) {
        return response.data['request_token'];
      } else {
        throw Exception('Failed to create request token');
      }
    } catch (e) {
      throw Exception('Error creating request token: $e');
    }
  }

  /// Step 2: Validate request token with login credentials
  Future<String> validateWithLogin({
    required String username,
    required String password,
    required String requestToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.validateWithLogin,
        data: {
          'username': username,
          'password': password,
          'request_token': requestToken,
        },
      );

      if (response.data['success'] == true) {
        return response.data['request_token'];
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      }
      throw Exception('Login failed: $e');
    }
  }

  /// Step 3: Create session with validated request token
  Future<String> createSession(String requestToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.createSession,
        data: {
          'request_token': requestToken,
        },
      );

      if (response.data['success'] == true) {
        return response.data['session_id'];
      } else {
        throw Exception('Failed to create session');
      }
    } catch (e) {
      throw Exception('Error creating session: $e');
    }
  }

  /// Complete login flow
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Step 1: Create request token
      final requestToken = await createRequestToken();
      
      // Step 2: Validate with login
      final validatedToken = await validateWithLogin(
        username: username,
        password: password,
        requestToken: requestToken,
      );
      
      // Step 3: Create session
      final sessionId = await createSession(validatedToken);
      
      // Get account details
      final accountDetails = await getAccountDetails(sessionId);
      
      return {
        'session_id': sessionId,
        'account_details': accountDetails,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get account details
  Future<Map<String, dynamic>> getAccountDetails(String sessionId) async {
    try {
      final response = await _dio.get(
        ApiConstants.accountDetails,
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Error getting account details: $e');
    }
  }

  /// Delete session (logout)
  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.deleteSession,
        data: {
          'session_id': sessionId,
        },
      );
      
      return response.data['success'] == true;
    } catch (e) {
      // Even if the API call fails, we should still clear local data
      return true;
    }
  }

  /// Get movie account states (favorite, watchlist, rated)
  Future<Map<String, dynamic>> getMovieAccountStates({
    required int movieId,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.accountStates}/$movieId/account_states',
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Error getting movie account states: $e');
    }
  }

  /// Add movie to watchlist
  Future<bool> addToWatchlist({
    required int accountId,
    required int movieId,
    required bool watchlist,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.addToWatchlist.replaceAll('{account_id}', accountId.toString()),
        data: {
          'media_type': 'movie',
          'media_id': movieId,
          'watchlist': watchlist,
        },
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error updating watchlist: $e');
    }
  }

  /// Add movie to favorites
  Future<bool> addToFavorites({
    required int accountId,
    required int movieId,
    required bool favorite,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.addToFavorites.replaceAll('{account_id}', accountId.toString()),
        data: {
          'media_type': 'movie',
          'media_id': movieId,
          'favorite': favorite,
        },
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error updating favorites: $e');
    }
  }

  /// Rate a movie
  Future<bool> rateMovie({
    required int movieId,
    required double rating,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.rateMovie}/$movieId/rating',
        data: {
          'value': rating,
        },
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error rating movie: $e');
    }
  }

  /// Get user's watchlist
  Future<List<dynamic>> getWatchlist({
    required int accountId,
    required String sessionId,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.getWatchlist.replaceAll('{account_id}', accountId.toString()),
        queryParameters: {
          'session_id': sessionId,
          'page': page,
        },
      );
      
      return response.data['results'] ?? [];
    } catch (e) {
      throw Exception('Error getting watchlist: $e');
    }
  }

  /// Get user's favorites
  Future<List<dynamic>> getFavorites({
    required int accountId,
    required String sessionId,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.getFavorites.replaceAll('{account_id}', accountId.toString()),
        queryParameters: {
          'session_id': sessionId,
          'page': page,
        },
      );
      
      return response.data['results'] ?? [];
    } catch (e) {
      throw Exception('Error getting favorites: $e');
    }
  }

  /// Get user's rated movies
  Future<List<dynamic>> getRatedMovies({
    required int accountId,
    required String sessionId,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.getRatedMovies.replaceAll('{account_id}', accountId.toString()),
        queryParameters: {
          'session_id': sessionId,
          'page': page,
        },
      );
      
      return response.data['results'] ?? [];
    } catch (e) {
      throw Exception('Error getting rated movies: $e');
    }
  }

  /// Get watch providers for a movie
  Future<Map<String, dynamic>?> getWatchProviders({
    required int movieId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.watchProviders}/$movieId/watch/providers',
      );
      
      return response.data['results'];
    } catch (e) {
      // Return null if no watch providers found
      return null;
    }
  }

  /// Get user's lists
  Future<List<dynamic>> getUserLists({
    required int accountId,
    required String sessionId,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.getUserLists.replaceAll('{account_id}', accountId.toString()),
        queryParameters: {
          'session_id': sessionId,
          'page': page,
        },
      );
      
      return response.data['results'] ?? [];
    } catch (e) {
      throw Exception('Error getting user lists: $e');
    }
  }

  /// Create a new list
  Future<Map<String, dynamic>> createList({
    required String name,
    required String description,
    required String sessionId,
    String language = 'en',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.createList,
        data: {
          'name': name,
          'description': description,
          'language': language,
        },
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Error creating list: $e');
    }
  }

  /// Get list details
  Future<Map<String, dynamic>> getList({
    required int listId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getList}/$listId',
      );
      
      return response.data;
    } catch (e) {
      throw Exception('Error getting list: $e');
    }
  }

  /// Add movie to list
  Future<bool> addMovieToList({
    required int listId,
    required int movieId,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.addMovieToList}/$listId/add_item',
        data: {
          'media_id': movieId,
        },
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error adding movie to list: $e');
    }
  }

  /// Remove movie from list
  Future<bool> removeMovieFromList({
    required int listId,
    required int movieId,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.removeMovieFromList}/$listId/remove_item',
        data: {
          'media_id': movieId,
        },
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error removing movie from list: $e');
    }
  }

  /// Delete a list
  Future<bool> deleteList({
    required int listId,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.deleteList}/$listId',
        queryParameters: {
          'session_id': sessionId,
        },
      );
      
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Error deleting list: $e');
    }
  }
}