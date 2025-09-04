import 'package:flutter/material.dart';

import '../../core/network/api_result.dart';
import '../../domain/entities/filter_options.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/paginated_response.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/remote/movie_remote_datasource.dart';
import '../datasources/local/movie_local_datasource.dart';
import '../models/movie_model.dart';
import '../models/hive/cached_movie_detail_model.dart';
import '../models/movie_response_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;
  final MovieLocalDataSource _localDataSource;

  MovieRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<ApiResult<PaginatedResponse<Movie>>> getPopularMovies({int page = 1}) async {
    return _getCachedMoviesWithRefresh('popular', page: page);
  }

  @override
  Future<ApiResult<PaginatedResponse<Movie>>> getTopRatedMovies({int page = 1}) async {
    return _getCachedMoviesWithRefresh('top_rated', page: page);
  }

  @override
  Future<ApiResult<PaginatedResponse<Movie>>> getNowPlayingMovies({int page = 1}) async {
    return _getCachedMoviesWithRefresh('now_playing', page: page);
  }

  @override
  Future<ApiResult<PaginatedResponse<Movie>>> getTrendingMovies({int page = 1}) async {
    return _getCachedMoviesWithRefresh('trending', page: page);
  }

  @override
  Future<ApiResult<PaginatedResponse<Movie>>> searchMovies(String query, {int page = 1}) async {
    try {
      print("Line 45");
      // 1. Search in cached data first
      final cachedResult = await _localDataSource.searchMovies(query);
      List<Movie> cachedMovies = [];
      
      if (cachedResult is Success<List<MovieModel>> && cachedResult.data.isNotEmpty) {
        cachedMovies = cachedResult.data.map((m) => m.toEntity()).toList();
      }

      // 2. Perform API search and cache results
      final ApiResult<MovieResponseModel> response = await _remoteDataSource.searchMovies(query, page: page);
      print("Line 56");
      if (response is Success) {
        final successResponse = response as Success<MovieResponseModel>;
        final movieResponse = successResponse.data;
        // Cache search results
        await _cacheSearchResults(movieResponse.results.map((m) => m.toJson()).toList(), query);
        
        // Combine and deduplicate results (API results first, then cached)
        final combinedResults = _combineSearchResults(
          movieResponse.results.map((model) => model.toEntity()).toList(),
          cachedMovies,
        );

        print("Line 74");
        
        return Success(PaginatedResponse<Movie>(
          results: combinedResults,
          page: movieResponse.page,
          totalPages: movieResponse.totalPages,
          totalResults: movieResponse.totalResults,
        ));
      } else if (response is Failure) {
        print("response is Failure Line 81");
        final failureResponse = response as Failure;
        if (cachedMovies.isNotEmpty) {
          // Return cached results with fake pagination data
          return Success(PaginatedResponse<Movie>(
            results: cachedMovies,
            page: 1,
            totalPages: 1,
            totalResults: cachedMovies.length,
          ));
        } else {
          return Failure(failureResponse.message, code: failureResponse.code);
        }
      }
      
      return Failure('Unknown error occurred');
    } catch (e) {
      return Failure('Search failed: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<PaginatedResponse<Movie>>> searchMoviesWithFilters(
    String query,
    FilterOptions filters, {
    int page = 1,
  }) async {
    try {
      final filterParams = filters.toQueryParameters();
      final response = await _remoteDataSource.searchMoviesWithFilters(
        query,
        filterParams,
        page: page,
      );

      return switch (response) {
        Success(data: final movieResponse) => Success(
          PaginatedResponse<Movie>(
            results: movieResponse.results.map((model) => model.toEntity()).toList(),
            page: movieResponse.page,
            totalPages: movieResponse.totalPages,
            totalResults: movieResponse.totalResults,
          ),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Filtered search failed: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<PaginatedResponse<Movie>>> discoverMovies(
    FilterOptions filters, {
    int page = 1,
  }) async {
    try {
      final filterParams = filters.toQueryParameters();
      final response = await _remoteDataSource.discoverMovies(
        filterParams,
        page: page,
      );

      return switch (response) {
        Success(data: final movieResponse) => Success(
          PaginatedResponse<Movie>(
            results: movieResponse.results.map((model) => model.toEntity()).toList(),
            page: movieResponse.page,
            totalPages: movieResponse.totalPages,
            totalResults: movieResponse.totalResults,
          ),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Discovery failed: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<MovieDetail>> getMovieDetails(int movieId) async {
    try {
      // 1. Always return cached detail first (if available)
      final cachedResult = await _localDataSource.getMovieDetail(movieId);

      CachedMovieDetailModel? cachedDetail;
      if (cachedResult is Success<CachedMovieDetailModel?> && cachedResult.data != null) {
        cachedDetail = cachedResult.data!;
      }

      // 2. Check if we need to refresh
      final isStaleResult = await _localDataSource.isMovieDetailStale(movieId);
      final needsRefresh = isStaleResult is Success<bool> ? isStaleResult.data : true;

      // 3. If cache is fresh, return cached data
      if (!needsRefresh && cachedDetail != null) {
        return Success(cachedDetail.toEntity());
      }

      // 4. If we have cached data, check for changes first
      if (cachedDetail != null && !cachedDetail.isStale) {
        final hasChanges = await _checkForMovieChanges(movieId, cachedDetail);
        if (!hasChanges) {
          // No changes, update timestamp and return cached data
          await _localDataSource.updateMovieDetail(
            cachedDetail.copyWith(lastUpdated: DateTime.now()),
          );
          return Success(cachedDetail.toEntity());
        }
      }

      // 5. Fetch fresh data and update cache
      final detailResult = await _remoteDataSource.getMovieDetails(movieId);
      final creditsResult = await _remoteDataSource.getMovieCredits(movieId);

      if (detailResult is Success) {
        final successDetailResult = detailResult as Success;
        final detailModel = successDetailResult.data;
        if (creditsResult is Success) {
          final successCreditsResult = creditsResult as Success;
          final creditsModel = successCreditsResult.data;
          // Save to cache with cast
          await _saveMovieDetailToCache(
            detailModel.toJson(),
            creditsModel.cast.map((c) => c.toJson()).toList(),
          );
          return Success(detailModel.toEntity(cast: creditsModel.cast));
        }
        else {
          // Save to cache without cast
          await _saveMovieDetailToCache(detailModel.toJson(), []);
          return Success(detailModel.toEntity());
        }
      } else if (detailResult is Failure) {
        final failureDetailResult = detailResult as Failure;
        // If API fails but we have cached data, return it
        if (cachedDetail != null) {
          return Success(cachedDetail.toEntity());
        } else {
          return Failure(failureDetailResult.message, code: failureDetailResult.code);
        }
      }

      return Failure('Unknown error occurred');
    } catch (e) {
      return Failure('Failed to get movie details: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<Cast>>> getMovieCredits(int movieId) async {
    try {
      final result = await _remoteDataSource.getMovieCredits(movieId);

      return switch (result) {
        Success(data: final creditsModel) => Success(
          creditsModel.cast.map((model) => model.toEntity()).toList(),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Failed to get movie credits: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<Movie>>> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      final result = await _remoteDataSource.getSimilarMovies(movieId, page: page);

      return switch (result) {
        Success(data: final response) => Success(
          response.results.map((model) => model.toEntity()).toList(),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Failed to get similar movies: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<List<Movie>>> getPersonMovies(int personId, {int page = 1}) async {
    try {
      final result = await _remoteDataSource.getPersonMovies(personId, page: page);

      return switch (result) {
        Success(data: final response) => Success(
          response.results.map((model) => model.toEntity()).toList(),
        ),
        Failure(message: final message, code: final code) => Failure(message, code: code),
      };
    } catch (e) {
      return Failure('Failed to get person movies: ${e.toString()}');
    }
  }

  // Cache-first implementation methods
  Future<ApiResult<PaginatedResponse<Movie>>> _getCachedMoviesWithRefresh(
    String category, {
    int page = 1,
  }) async {
    try {
      // 1. Always return cached data first (if available)
      final cachedResult = await _localDataSource.getMoviesByCategory(
        category,
        page: page,
      );

      List<Movie> cachedMovies = [];
      if (cachedResult is Success<List<MovieModel>> && cachedResult.data.isNotEmpty) {
        cachedMovies = cachedResult.data.map((m) => m.toEntity()).toList();
      }

      // 2. Check if cache needs refresh
      final isStaleResult = await _localDataSource.isCategoryStale(category, page: page);
      final isStale = isStaleResult is Success<bool> ? isStaleResult.data : true;

      // 3. If cache is fresh, return cached data
      if (!isStale && cachedMovies.isNotEmpty) {
        // For cached data, we don't have real pagination info, so we estimate
        return Success(PaginatedResponse<Movie>(
          results: cachedMovies,
          page: page,
          totalPages: page + 1, // Assume there might be more pages
          totalResults: cachedMovies.length * page, // Rough estimate
        ));
      }

      // 4. Try to fetch fresh data from API
      final freshResult = await _fetchFreshCategoryData(category, page: page);
      if (freshResult is Success) {
        return freshResult;
      }

      // 5. If API fails, return cached data (or empty if no cache)
      return Success(PaginatedResponse<Movie>(
        results: cachedMovies,
        page: page,
        totalPages: cachedMovies.isEmpty ? 0 : page,
        totalResults: cachedMovies.length,
      ));
    } catch (e) {
      return Failure('Failed to get movies: ${e.toString()}');
    }
  }

  Future<ApiResult<PaginatedResponse<Movie>>> _fetchFreshCategoryData(String category, {int page = 1}) async {
    try {
      late ApiResult<MovieResponseModel> result;
      
      switch (category) {
        case 'popular':
          result = await _remoteDataSource.getPopularMovies(page: page);
          break;
        case 'top_rated':
          result = await _remoteDataSource.getTopRatedMovies(page: page);
          break;
        case 'now_playing':
          result = await _remoteDataSource.getNowPlayingMovies(page: page);
          break;
        case 'trending':
          result = await _remoteDataSource.getTrendingMovies(page: page);
          break;
        default:
          return Failure('Unknown category: $category');
      }

      if (result is Success) {
        final movieResponse = (result as Success<MovieResponseModel>).data;
        
        // Cache the results
        final movies = movieResponse.results
            .map((model) => MovieModel.fromApiResponse(
                  model.toJson(),
                  category: category,
                ))
            .toList();

        await _localDataSource.saveMovies(movies, category, page: page);
        
        // Return paginated response
        return Success(PaginatedResponse<Movie>(
          results: movieResponse.results.map((model) => model.toEntity()).toList(),
          page: movieResponse.page,
          totalPages: movieResponse.totalPages,
          totalResults: movieResponse.totalResults,
        ));
      } else {
        return Failure((result as Failure).message, code: (result as Failure).code);
      }
    } catch (e) {
      return Failure('Failed to fetch fresh data for $category: ${e.toString()}');
    }
  }



  Future<bool> _checkForMovieChanges(int movieId, CachedMovieDetailModel cachedDetail) async {
    try {
      final lastUpdate = cachedDetail.lastUpdated ?? cachedDetail.cachedAt;
      final startDate = lastUpdate.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      final changesResult = await _remoteDataSource.getMovieChanges(
        movieId,
        startDate: startDate,
      );

      if (changesResult is Success<Map<String, dynamic>>) {
        final changes = changesResult.data['changes'] as List<dynamic>?;
        return changes != null && changes.isNotEmpty;
      }
      
      return true; // Assume changes if we can't check
    } catch (e) {
      return true; // Assume changes on error
    }
  }

  Future<void> _saveMovieDetailToCache(
    Map<String, dynamic> detailJson,
    List<Map<String, dynamic>> castJson,
  ) async {
    try {
      final cachedDetail = CachedMovieDetailModel.fromApiResponse(detailJson, castJson);
      await _localDataSource.saveMovieDetail(cachedDetail);
    } catch (e) {
      debugPrint('Failed to save movie detail to cache: $e');
    }
  }

  List<Movie> _combineSearchResults(List<Movie> apiResults, List<Movie> cachedResults) {
    final combined = <int, Movie>{};
    
    // Add API results first (higher priority)
    for (final movie in apiResults) {
      combined[movie.id] = movie;
    }
    
    // Add cached results that aren't already present
    for (final movie in cachedResults) {
      if (!combined.containsKey(movie.id)) {
        combined[movie.id] = movie;
      }
    }
    
    return combined.values.toList();
  }

  Future<void> _cacheSearchResults(List<Map<String, dynamic>> results, String query) async {
    try {
      final movies = results
          .map((json) => MovieModel.fromApiResponse(json, category: 'search'))
          .toList();
      
      // Save individual movies to cache
      for (final movie in movies) {
        await _localDataSource.updateMovie(movie);
      }
    } catch (e) {
      debugPrint('Failed to cache search results: $e');
    }
  }
}