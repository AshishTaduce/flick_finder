import '../services/tmdb_auth_service.dart';
import '../services/settings_service.dart';
import '../../domain/entities/watch_provider.dart';
import '../../data/models/watch_provider_model.dart';

class WatchProvidersService {
  static WatchProvidersService? _instance;
  static WatchProvidersService get instance => _instance ??= WatchProvidersService._();
  WatchProvidersService._();

  /// Get watch providers for a movie in the user's region
  Future<WatchProviders?> getWatchProviders(int movieId) async {
    try {
      final providersData = await TmdbAuthService.instance.getWatchProviders(
        movieId: movieId,
      );
      
      if (providersData == null) return null;
      
      // Get user's region
      final region = await SettingsService.instance.getRegion();
      
      // Get providers for user's region
      final regionData = providersData[region];
      if (regionData == null) return null;
      
      final watchProvidersModel = WatchProvidersModel.fromJson(regionData);
      return watchProvidersModel.toEntity();
    } catch (e) {
      return null;
    }
  }
}