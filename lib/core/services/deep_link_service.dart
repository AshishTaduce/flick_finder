import 'package:flutter/services.dart';

class DeepLinkService {
  static const String _scheme = 'flickfinder';
  static const String _host = 'movie';
  
  static DeepLinkService? _instance;
  static DeepLinkService get instance => _instance ??= DeepLinkService._();
  DeepLinkService._();

  /// Generate a deep link URL for a movie
  static String generateMovieLink(int movieId) {
    return '$_scheme://$_host/$movieId';
  }

  /// Generate a web fallback URL for a movie
  static String generateWebLink(int movieId) {
    return 'https://flickfinder.app/movie/$movieId';
  }

  /// Generate a universal link that works for both app and web
  static String generateUniversalLink(int movieId) {
    return 'https://flickfinder.app/?movie=$movieId';
  }

  /// Parse movie ID from a deep link URL
  static int? parseMovieId(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Handle app deep link: flickfinder://movie/123
      if (uri.scheme == _scheme && uri.host == _host) {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          return int.tryParse(segments.first);
        }
      }
      
      // Handle web link: https://flickfinder.app/movie/123
      if (uri.scheme == 'https' && uri.host == 'flickfinder.app') {
        final segments = uri.pathSegments;
        if (segments.length >= 2 && segments[0] == 'movie') {
          return int.tryParse(segments[1]);
        }
        
        // Handle query parameter: https://flickfinder.app/?movie=123
        final movieParam = uri.queryParameters['movie'];
        if (movieParam != null) {
          return int.tryParse(movieParam);
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Copy movie link to clipboard
  static Future<void> copyMovieLink(int movieId) async {
    final link = generateUniversalLink(movieId);
    await Clipboard.setData(ClipboardData(text: link));
  }
}