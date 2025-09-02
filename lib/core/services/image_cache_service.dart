import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ImageCacheService {
  static ImageCacheService? _instance;
  static ImageCacheService get instance => _instance ??= ImageCacheService._();
  ImageCacheService._();

  final Dio _dio = Dio();
  Directory? _cacheDirectory;
  
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiry = Duration(days: 30);

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/image_cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      // Clean up expired images on startup
      _cleanupExpiredImages();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing image cache: $e');
      }
    }
  }

  Future<String?> getCachedImagePath(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty || _cacheDirectory == null) {
      return null;
    }

    final fileName = _getFileNameFromPath(imagePath);
    final cachedFile = File('${_cacheDirectory!.path}/$fileName');
    
    if (await cachedFile.exists()) {
      // Check if file is not expired
      final fileStat = await cachedFile.stat();
      final age = DateTime.now().difference(fileStat.modified);
      
      if (age < cacheExpiry) {
        return cachedFile.path;
      } else {
        // Delete expired file
        await cachedFile.delete();
      }
    }
    
    return null;
  }

  Future<String?> cacheImage(String imagePath) async {
    if (_cacheDirectory == null) return null;
    
    try {
      final imageUrl = '${ApiConstants.imageBaseUrl}$imagePath';
      final fileName = _getFileNameFromPath(imagePath);
      final cachedFile = File('${_cacheDirectory!.path}/$fileName');
      
      // Download and cache the image
      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      
      await cachedFile.writeAsBytes(response.data);
      
      // Check cache size and cleanup if needed
      _checkCacheSizeAndCleanup();
      
      return cachedFile.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error caching image $imagePath: $e');
      }
      return null;
    }
  }

  Future<void> preloadImages(List<String> imagePaths) async {
    if (_cacheDirectory == null) return;
    
    final futures = <Future>[];
    
    for (final imagePath in imagePaths) {
      if (imagePath.isNotEmpty) {
        final cachedPath = await getCachedImagePath(imagePath);
        if (cachedPath == null) {
          // Image not cached, add to preload queue
          futures.add(cacheImage(imagePath));
        }
      }
    }
    
    // Limit concurrent downloads
    const batchSize = 5;
    for (int i = 0; i < futures.length; i += batchSize) {
      final batch = futures.skip(i).take(batchSize);
      await Future.wait(batch);
    }
  }

  String _getFileNameFromPath(String imagePath) {
    // Create a safe filename from the image path
    return imagePath.replaceAll('/', '_').replaceAll('\\', '_');
  }

  Future<void> _cleanupExpiredImages() async {
    if (_cacheDirectory == null) return;
    
    try {
      final files = await _cacheDirectory!.list().toList();
      final now = DateTime.now();
      
      for (final file in files) {
        if (file is File) {
          final fileStat = await file.stat();
          final age = now.difference(fileStat.modified);
          
          if (age > cacheExpiry) {
            await file.delete();
            if (kDebugMode) {
              print('Deleted expired cached image: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up expired images: $e');
      }
    }
  }

  Future<void> _checkCacheSizeAndCleanup() async {
    if (_cacheDirectory == null) return;
    
    try {
      final files = await _cacheDirectory!.list().toList();
      int totalSize = 0;
      final fileStats = <MapEntry<File, FileStat>>[];
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          fileStats.add(MapEntry(file, stat));
        }
      }
      
      if (totalSize > maxCacheSize) {
        // Sort by last modified (oldest first)
        fileStats.sort((a, b) => a.value.modified.compareTo(b.value.modified));
        
        // Delete oldest files until under limit
        for (final entry in fileStats) {
          if (totalSize <= maxCacheSize * 0.8) break; // Leave some buffer
          
          await entry.key.delete();
          totalSize -= entry.value.size;
          
          if (kDebugMode) {
            print('Deleted cached image for size limit: ${entry.key.path}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking cache size: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    if (_cacheDirectory == null) {
      return {'files': 0, 'size': 0, 'sizeFormatted': '0 B'};
    }
    
    try {
      final files = await _cacheDirectory!.list().toList();
      int totalSize = 0;
      int fileCount = 0;
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          fileCount++;
        }
      }
      
      return {
        'files': fileCount,
        'size': totalSize,
        'sizeFormatted': _formatBytes(totalSize),
      };
    } catch (e) {
      return {'files': 0, 'size': 0, 'sizeFormatted': '0 B'};
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> clearCache() async {
    if (_cacheDirectory == null) return;
    
    try {
      final files = await _cacheDirectory!.list().toList();
      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }
      if (kDebugMode) {
        print('Image cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing image cache: $e');
      }
    }
  }
}