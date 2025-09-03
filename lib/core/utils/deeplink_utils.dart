import 'package:share_plus/share_plus.dart';
import '../services/deeplink_service.dart';

class DeepLinkUtils {
  /// Generate a custom scheme deeplink for a movie
  static String generateMovieLink(int movieId) {
    return DeepLinkService.generateMovieDeepLink(movieId);
  }

  /// Parse a deeplink and extract movie ID
  static int? parseMovieId(String link) {
    try {
      final uri = Uri.tryParse(link);
      if (uri != null) {
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2 && pathSegments[0] == 'movie') {
          return int.tryParse(pathSegments[1]);
        }
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  /// Check if a link is a valid movie deeplink
  static bool isValidMovieLink(String link) {
    return parseMovieId(link) != null;
  }

  /// Share movie with deep link
  static Future<void> shareMovie(int movieId, String movieTitle) async {
    final deepLink = generateMovieLink(movieId);
    final shareText = 'Check out "$movieTitle" on FlickFinder: $deepLink';
    
    await Share.share(
      shareText,
      subject: 'Movie Recommendation: $movieTitle',
    );
  }
}