import '../../../core/services/hive_service.dart';
import '../../../core/network/api_result.dart';
import '../../models/hive/cached_movie_model.dart';
import '../../models/hive/cached_movie_detail_model.dart';
import '../../models/hive/cache_metadata_model.dart';

class MovieLocalDataSource {
  final HiveService _hiveService = HiveService.instance;

  // Movies CRUD operations
  Future<ApiResult<List<CachedMovieModel>>> getMoviesByCategory(
    String category, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final box = _hiveService.moviesBox;
      final allMovies = box.values
          .where((movie) => movie.category == category)
          .toList();

      // Sort by cached date (newest first)
      allMovies.sort((a, b) => b.cachedAt.compareTo(a.cachedAt));

      // Implement pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      
      final paginatedMovies = allMovies.length > startIndex
          ? allMovies.sublist(
              startIndex,
              endIndex > allMovies.length ? allMovies.length : endIndex,
            )
          : <CachedMovieModel>[];

      return Success(paginatedMovies);
    } catch (e) {
      return Failure('Failed to get cached movies: ${e.toString()}');
    }
  }

  Future<ApiResult<CachedMovieModel?>> getMovieById(int movieId) async {
    try {
      final box = _hiveService.moviesBox;
      final movie = box.get(movieId.toString());
      return Success(movie);
    } catch (e) {
      return Failure('Failed to get cached movie: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> saveMovies(
    List<CachedMovieModel> movies,
    String category, {
    int? page,
  }) async {
    try {
      final box = _hiveService.moviesBox;
      final metadataBox = _hiveService.cacheMetadataBox;

      // Save movies
      final movieMap = <String, CachedMovieModel>{};
      for (final movie in movies) {
        final updatedMovie = movie.copyWith(
          category: category,
          lastUpdated: DateTime.now(),
        );
        movieMap[movie.id.toString()] = updatedMovie;
      }
      await box.putAll(movieMap);

      // Save metadata
      final metadataKey = '${category}_page_${page ?? 1}';
      final metadata = CacheMetadataModel(
        key: metadataKey,
        lastFetched: DateTime.now(),
        lastUpdated: DateTime.now(),
        additionalData: {
          'category': category,
          'page': page ?? 1,
          'count': movies.length,
        },
      );
      await metadataBox.put(metadataKey, metadata);

      return const Success(null);
    } catch (e) {
      return Failure('Failed to save movies: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> updateMovie(CachedMovieModel movie) async {
    try {
      final box = _hiveService.moviesBox;
      final updatedMovie = movie.copyWith(lastUpdated: DateTime.now());
      await box.put(movie.id.toString(), updatedMovie);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update movie: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> deleteMovie(int movieId) async {
    try {
      final box = _hiveService.moviesBox;
      await box.delete(movieId.toString());
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete movie: ${e.toString()}');
    }
  }

  // Movie Details CRUD operations
  Future<ApiResult<CachedMovieDetailModel?>> getMovieDetail(int movieId) async {
    try {
      final box = _hiveService.movieDetailsBox;
      final detail = box.get(movieId.toString());
      return Success(detail);
    } catch (e) {
      return Failure('Failed to get cached movie detail: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> saveMovieDetail(CachedMovieDetailModel detail) async {
    try {
      final box = _hiveService.movieDetailsBox;
      final metadataBox = _hiveService.cacheMetadataBox;

      // Save movie detail
      await box.put(detail.id.toString(), detail);

      // Save metadata
      final metadataKey = 'movie_detail_${detail.id}';
      final metadata = CacheMetadataModel(
        key: metadataKey,
        lastFetched: DateTime.now(),
        lastUpdated: DateTime.now(),
        additionalData: {
          'movieId': detail.id,
          'lastChangeId': detail.lastChangeId,
        },
      );
      await metadataBox.put(metadataKey, metadata);

      return const Success(null);
    } catch (e) {
      return Failure('Failed to save movie detail: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> updateMovieDetail(CachedMovieDetailModel detail) async {
    try {
      final box = _hiveService.movieDetailsBox;
      final updatedDetail = detail.copyWith(lastUpdated: DateTime.now());
      await box.put(detail.id.toString(), updatedDetail);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update movie detail: ${e.toString()}');
    }
  }

  // Search operations
  Future<ApiResult<List<CachedMovieModel>>> searchMovies(String query) async {
    try {
      final box = _hiveService.moviesBox;
      final searchQuery = query.toLowerCase();
      
      final results = box.values
          .where((movie) =>
              movie.title.toLowerCase().contains(searchQuery) ||
              movie.description.toLowerCase().contains(searchQuery))
          .toList();

      // Sort by relevance (title matches first, then description)
      results.sort((a, b) {
        final aTitle = a.title.toLowerCase().contains(searchQuery);
        final bTitle = b.title.toLowerCase().contains(searchQuery);
        
        if (aTitle && !bTitle) return -1;
        if (!aTitle && bTitle) return 1;
        
        // If both or neither match title, sort by rating
        return b.rating.compareTo(a.rating);
      });

      return Success(results.take(50).toList()); // Limit search results
    } catch (e) {
      return Failure('Failed to search cached movies: ${e.toString()}');
    }
  }

  // Cache management
  Future<ApiResult<CacheMetadataModel?>> getCacheMetadata(String key) async {
    try {
      final box = _hiveService.cacheMetadataBox;
      final metadata = box.get(key);
      return Success(metadata);
    } catch (e) {
      return Failure('Failed to get cache metadata: ${e.toString()}');
    }
  }

  Future<ApiResult<bool>> isCategoryStale(String category, {int? page}) async {
    try {
      final metadataKey = '${category}_page_${page ?? 1}';
      final metadataResult = await getCacheMetadata(metadataKey);
      
      if (metadataResult is Success<CacheMetadataModel?> && metadataResult.data != null) {
        final metadata = metadataResult.data!;
        
        // Different staleness thresholds for different categories
        Duration staleThreshold;
        switch (category) {
          case 'popular':
          case 'trending':
            staleThreshold = const Duration(hours: 6);
            break;
          case 'now_playing':
            staleThreshold = const Duration(hours: 12);
            break;
          default:
            staleThreshold = const Duration(hours: 24);
        }
        
        return Success(metadata.isStale(staleThreshold));
      }
      
      return const Success(true); // No metadata means stale
    } catch (e) {
      return Failure('Failed to check staleness: ${e.toString()}');
    }
  }

  Future<ApiResult<bool>> isMovieDetailStale(int movieId) async {
    try {
      final detailResult = await getMovieDetail(movieId);
      
      if (detailResult is Success<CachedMovieDetailModel?> && detailResult.data != null) {
        final detail = detailResult.data!;
        return Success(detail.needsRefresh);
      }
      
      return const Success(true); // No cached detail means stale
    } catch (e) {
      return Failure('Failed to check movie detail staleness: ${e.toString()}');
    }
  }

  // User data operations
  Future<ApiResult<List<int>>> getFavoriteMovieIds() async {
    try {
      final box = _hiveService.userDataBox;
      final favorites = box.get('favorite_movies');
      if (favorites != null && favorites['ids'] is List) {
        return Success(List<int>.from(favorites['ids']));
      }
      return const Success([]);
    } catch (e) {
      return Failure('Failed to get favorite movies: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> saveFavoriteMovieIds(List<int> movieIds) async {
    try {
      final box = _hiveService.userDataBox;
      await box.put('favorite_movies', {
        'ids': movieIds,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      return const Success(null);
    } catch (e) {
      return Failure('Failed to save favorite movies: ${e.toString()}');
    }
  }

  Future<ApiResult<List<int>>> getWatchlistMovieIds() async {
    try {
      final box = _hiveService.userDataBox;
      final watchlist = box.get('watchlist_movies');
      if (watchlist != null && watchlist['ids'] is List) {
        return Success(List<int>.from(watchlist['ids']));
      }
      return const Success([]);
    } catch (e) {
      return Failure('Failed to get watchlist movies: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> saveWatchlistMovieIds(List<int> movieIds) async {
    try {
      final box = _hiveService.userDataBox;
      await box.put('watchlist_movies', {
        'ids': movieIds,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      return const Success(null);
    } catch (e) {
      return Failure('Failed to save watchlist movies: ${e.toString()}');
    }
  }

  // Statistics and maintenance
  Future<ApiResult<Map<String, int>>> getCacheStats() async {
    try {
      final moviesCount = _hiveService.moviesBox.length;
      final detailsCount = _hiveService.movieDetailsBox.length;
      final metadataCount = _hiveService.cacheMetadataBox.length;
      
      return Success({
        'movies': moviesCount,
        'details': detailsCount,
        'metadata': metadataCount,
        'total': moviesCount + detailsCount + metadataCount,
      });
    } catch (e) {
      return Failure('Failed to get cache stats: ${e.toString()}');
    }
  }

  Future<ApiResult<void>> clearExpiredCache() async {
    try {
      final moviesBox = _hiveService.moviesBox;
      final detailsBox = _hiveService.movieDetailsBox;
      
      // Remove stale movies
      final staleMovieKeys = <String>[];
      for (final key in moviesBox.keys) {
        final movie = moviesBox.get(key);
        if (movie != null && movie.isStale) {
          staleMovieKeys.add(key.toString());
        }
      }
      await moviesBox.deleteAll(staleMovieKeys);
      
      // Remove stale details
      final staleDetailKeys = <String>[];
      for (final key in detailsBox.keys) {
        final detail = detailsBox.get(key);
        if (detail != null && detail.isStale) {
          staleDetailKeys.add(key.toString());
        }
      }
      await detailsBox.deleteAll(staleDetailKeys);
      
      return const Success(null);
    } catch (e) {
      return Failure('Failed to clear expired cache: ${e.toString()}');
    }
  }
}