import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/movie_detail_model.dart';
import '../../data/models/cast_model.dart';
import '../../data/models/hive/cache_metadata_model.dart';

class HiveService {
  static const String _moviesBoxName = 'movies';
  static const String _movieDetailsBoxName = 'movie_details';
  static const String _cacheMetadataBoxName = 'cache_metadata';
  static const String _userDataBoxName = 'user_data';

  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();
  HiveService._();

  Box<MovieModel>? _moviesBox;
  Box<MovieDetailModel>? _movieDetailsBox;
  Box<CacheMetadataModel>? _cacheMetadataBox;
  Box<Map<String, dynamic>>? _userDataBox;

  Box<MovieModel> get moviesBox => _moviesBox!;
  Box<MovieDetailModel> get movieDetailsBox => _movieDetailsBox!;
  Box<CacheMetadataModel> get cacheMetadataBox => _cacheMetadataBox!;
  Box<Map<String, dynamic>> get userDataBox => _userDataBox!;

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MovieModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GenreModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MovieDetailModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CastModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CacheMetadataModelAdapter());
    }

    // Open boxes
    _moviesBox = await Hive.openBox<MovieModel>(_moviesBoxName);
    _movieDetailsBox = await Hive.openBox<MovieDetailModel>(_movieDetailsBoxName);
    _cacheMetadataBox = await Hive.openBox<CacheMetadataModel>(_cacheMetadataBoxName);
    _userDataBox = await Hive.openBox<Map<String, dynamic>>(_userDataBoxName);

    // Perform initial cleanup
    await _performCleanup();
  }

  Future<void> _performCleanup() async {
    try {
      // Clean up stale movies (older than 30 days)
      final staleMovieKeys = <String>[];
      for (final key in _moviesBox!.keys) {
        final movie = _moviesBox!.get(key);
        if (movie != null) {
          final age = DateTime.now().difference(movie.cachedAt);
          if (age > const Duration(days: 30)) {
            staleMovieKeys.add(key.toString());
          }
        }
      }
      await _moviesBox!.deleteAll(staleMovieKeys);

      // Clean up stale movie details (older than 60 days)
      final staleDetailKeys = <String>[];
      for (final key in _movieDetailsBox!.keys) {
        final detail = _movieDetailsBox!.get(key);
        if (detail != null) {
          final age = DateTime.now().difference(detail.cachedAt);
          if (age > const Duration(days: 60)) {
            staleDetailKeys.add(key.toString());
          }
        }
      }
      await _movieDetailsBox!.deleteAll(staleDetailKeys);

      // Clean up old metadata (older than 7 days)
      final staleMetadataKeys = <String>[];
      for (final key in _cacheMetadataBox!.keys) {
        final metadata = _cacheMetadataBox!.get(key);
        if (metadata != null) {
          final age = DateTime.now().difference(metadata.lastFetched);
          if (age > const Duration(days: 7)) {
            staleMetadataKeys.add(key.toString());
          }
        }
      }
      await _cacheMetadataBox!.deleteAll(staleMetadataKeys);

      debugPrint('Cache cleanup completed. Removed ${staleMovieKeys.length} movies, ${staleDetailKeys.length} details, ${staleMetadataKeys.length} metadata entries.');
    } catch (e) {
      debugPrint('Error during cache cleanup: $e');
    }
  }

  Future<void> clearAllCache() async {
    await _moviesBox?.clear();
    await _movieDetailsBox?.clear();
    await _cacheMetadataBox?.clear();
  }

  Future<void> clearUserData() async {
    await _userDataBox?.clear();
  }

  Future<void> close() async {
    await _moviesBox?.close();
    await _movieDetailsBox?.close();
    await _cacheMetadataBox?.close();
    await _userDataBox?.close();
  }

  // Cache size management
  int get totalCacheSize {
    return (_moviesBox?.length ?? 0) + 
           (_movieDetailsBox?.length ?? 0) + 
           (_cacheMetadataBox?.length ?? 0);
  }

  Future<void> compactBoxes() async {
    await _moviesBox?.compact();
    await _movieDetailsBox?.compact();
    await _cacheMetadataBox?.compact();
    await _userDataBox?.compact();
  }
}