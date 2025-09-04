import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';

import '../../core/network/api_result.dart';
import '../../data/datasources/local/movie_local_datasource.dart';
import '../../data/datasources/remote/movie_remote_datasource.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/movie_detail_model.dart';

class BackgroundSyncService {
  static BackgroundSyncService? _instance;
  static BackgroundSyncService get instance => _instance ??= BackgroundSyncService._();
  BackgroundSyncService._();

  final MovieLocalDataSource _localDataSource = MovieLocalDataSource();
  final MovieRemoteDataSource _remoteDataSource = MovieRemoteDataSource();
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  StreamSubscription<NetworkStatus>? _networkSubscription;
  
  static const Duration syncInterval = Duration(hours: 6);
  static const List<String> categoriesToSync = ['popular', 'trending', 'now_playing'];

  Future<void> initialize() async {
    // Listen for network status changes
    _networkSubscription = _connectivityService.networkStatusStream.listen(
      (status) {
        if (status == NetworkStatus.online) {
          _onNetworkRestored();
        }
      },
    );

    // Start periodic sync if online
    if (_connectivityService.isOnline) {
      _startPeriodicSync();
    }
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) {
      if (_connectivityService.isOnline && !_isSyncing) {
        _performBackgroundSync();
      }
    });
  }

  void _onNetworkRestored() {
    if (kDebugMode) {
      debugPrint('Network restored - starting background sync');
    }
    
    // Perform immediate sync when network is restored
    _performBackgroundSync();
    
    // Start periodic sync
    _startPeriodicSync();
  }

  Future<void> _performBackgroundSync() async {
    if (_isSyncing || !_connectivityService.isOnline) return;

    _isSyncing = true;
    
    try {
      if (kDebugMode) {
        debugPrint('Starting background sync...');
      }

      final futures = <Future>[];
      
      // Sync each category
      for (final category in categoriesToSync) {
        futures.add(_syncCategory(category));
      }
      
      // Wait for all syncs to complete
      await Future.wait(futures);
      
      if (kDebugMode) {
        debugPrint('Background sync completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Background sync failed: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncCategory(String category) async {
    try {
      // Check if category needs refresh
      final isStaleResult = await _localDataSource.isCategoryStale(category);
      final isStale = isStaleResult is Success<bool> ? isStaleResult.data : true;
      
      if (!isStale) {
        if (kDebugMode) {
          debugPrint('Category $category is fresh, skipping sync');
        }
        return;
      }

      if (kDebugMode) {
        debugPrint('Syncing category: $category');
      }

      // Fetch fresh data from API
      final result = await _fetchCategoryData(category);
      
      if (result != null) {
        // Convert to cached models
        final movies = result.results
            .map((model) => MovieModel.fromApiResponse(
                  model.toJson(),
                  category: category,
                ))
            .toList();

        // Save to local storage
        await _localDataSource.saveMovies(movies, category, page: 1);
        
        if (kDebugMode) {
          debugPrint('Synced ${movies.length} movies for category $category');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to sync category $category: $e');
      }
    }
  }

  Future<dynamic> _fetchCategoryData(String category) async {
    switch (category) {
      case 'popular':
        final result = await _remoteDataSource.getPopularMovies();
        return switch (result) {
          Success(data: final data) => data,
          Failure() => null,
        };
      case 'trending':
        final result = await _remoteDataSource.getTrendingMovies();
        return switch (result) {
          Success(data: final data) => data,
          Failure() => null,
        };
      case 'now_playing':
        final result = await _remoteDataSource.getNowPlayingMovies();
        return switch (result) {
          Success(data: final data) => data,
          Failure() => null,
        };
      default:
        return null;
    }
  }

  Future<void> syncMovieDetails(List<int> movieIds) async {
    if (!_connectivityService.isOnline || movieIds.isEmpty) return;

    try {
      if (kDebugMode) {
        debugPrint('Syncing details for ${movieIds.length} movies');
      }

      final futures = <Future>[];
      
      // Limit concurrent requests
      const batchSize = 5;
      for (int i = 0; i < movieIds.length; i += batchSize) {
        final batch = movieIds.skip(i).take(batchSize);
        for (final movieId in batch) {
          futures.add(_syncMovieDetail(movieId));
        }
        
        // Wait for batch to complete before starting next batch
        await Future.wait(futures);
        futures.clear();
      }
      
      if (kDebugMode) {
        debugPrint('Movie details sync completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Movie details sync failed: $e');
      }
    }
  }

  Future<void> _syncMovieDetail(int movieId) async {
    try {
      // Check if movie detail needs refresh
      final isStaleResult = await _localDataSource.isMovieDetailStale(movieId);
      final needsRefresh = switch (isStaleResult) {
        Success(data: final data) => data,
        Failure() => true,
      };
      
      if (!needsRefresh) return;

      // Fetch movie details and credits
      final detailResult = await _remoteDataSource.getMovieDetails(movieId);
      final creditsResult = await _remoteDataSource.getMovieCredits(movieId);

      switch (detailResult) {
        case Success(data: final detailModel):
          final castData = switch (creditsResult) {
            Success(data: final data) => data.cast.map((c) => c.toJson()).toList(),
            Failure() => <Map<String, dynamic>>[],
          };

        // Save to cache
        final cachedDetail = MovieDetailModel.fromApiResponse(
          detailModel.toJson(),
          castData,
        );
        
          await _localDataSource.saveMovieDetail(cachedDetail);
        case Failure():
          // Handle failure case
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to sync movie detail $movieId: $e');
      }
    }
  }

  Future<void> forceSync() async {
    if (!_connectivityService.isOnline) {
      if (kDebugMode) {
        debugPrint('Cannot force sync - device is offline');
      }
      return;
    }

    await _performBackgroundSync();
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final cacheStats = await _localDataSource.getCacheStats();
    
    return {
      'isOnline': _connectivityService.isOnline,
      'isSyncing': _isSyncing,
      'lastSyncTime': DateTime.now().toIso8601String(), // TODO: Store actual last sync time
      'cacheStats': switch (cacheStats) {
        Success(data: final data) => data,
        Failure() => <String, dynamic>{},
      },
    };
  }

  void dispose() {
    _syncTimer?.cancel();
    _networkSubscription?.cancel();
  }
}