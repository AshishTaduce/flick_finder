import '../services/auth_service.dart';
import '../services/tmdb_auth_service.dart';
import '../../domain/entities/tmdb_list.dart';
import '../../domain/entities/tmdb_list_detail.dart';
import '../../data/models/tmdb_list_model.dart';

class TmdbListsService {
  static TmdbListsService? _instance;
  static TmdbListsService get instance => _instance ??= TmdbListsService._();
  TmdbListsService._();

  /// Check if user can access list features (not a guest)
  Future<bool> canAccessListFeatures() async {
    final isAuthenticated = await AuthService.instance.isAuthenticated();
    final isGuest = await AuthService.instance.isGuest();
    return isAuthenticated && !isGuest;
  }

  /// Get user's lists
  Future<List<TmdbList>> getUserLists({int page = 1}) async {
    if (!await canAccessListFeatures()) return [];
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      final accountId = await AuthService.instance.getAccountId();
      
      if (sessionId == null || accountId == null) {
        return [];
      }
      
      final results = await TmdbAuthService.instance.getUserLists(
        accountId: int.parse(accountId),
        sessionId: sessionId,
        page: page,
      );
      
      return results.map((json) => TmdbListModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Create a new list
  Future<TmdbList?> createList({
    required String name,
    required String description,
  }) async {
    if (!await canAccessListFeatures()) {
      throw Exception('Please login with your TMDB account to create lists');
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      
      if (sessionId == null) {
        throw Exception('Authentication required');
      }
      
      final result = await TmdbAuthService.instance.createList(
        name: name,
        description: description,
        sessionId: sessionId,
      );
      
      if (result['success'] == true) {
        // Return a basic list object with the new ID
        return TmdbList(
          id: result['list_id'],
          name: name,
          description: description,
          itemCount: 0,
          public: true,
          iso639_1: 'en',
        );
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get list details with movies
  Future<TmdbListDetail?> getListDetail(int listId) async {
    try {
      final result = await TmdbAuthService.instance.getList(listId: listId);
      return TmdbListDetailModel.fromJson(result).toDetailEntity();
    } catch (e) {
      return null;
    }
  }

  /// Add movie to list
  Future<bool> addMovieToList({
    required int listId,
    required int movieId,
  }) async {
    if (!await canAccessListFeatures()) {
      throw Exception('Please login with your TMDB account to manage lists');
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      
      if (sessionId == null) {
        throw Exception('Authentication required');
      }
      
      return await TmdbAuthService.instance.addMovieToList(
        listId: listId,
        movieId: movieId,
        sessionId: sessionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove movie from list
  Future<bool> removeMovieFromList({
    required int listId,
    required int movieId,
  }) async {
    if (!await canAccessListFeatures()) {
      throw Exception('Please login with your TMDB account to manage lists');
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      
      if (sessionId == null) {
        throw Exception('Authentication required');
      }
      
      return await TmdbAuthService.instance.removeMovieFromList(
        listId: listId,
        movieId: movieId,
        sessionId: sessionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a list
  Future<bool> deleteList(int listId) async {
    if (!await canAccessListFeatures()) {
      throw Exception('Please login with your TMDB account to manage lists');
    }
    
    try {
      final sessionId = await AuthService.instance.getSessionId();
      
      if (sessionId == null) {
        throw Exception('Authentication required');
      }
      
      return await TmdbAuthService.instance.deleteList(
        listId: listId,
        sessionId: sessionId,
      );
    } catch (e) {
      rethrow;
    }
  }
}