import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _languageKey = 'app_language';
  static const String _regionKey = 'app_region';

  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();
  SettingsService._();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get current language (defaults to 'en-US')
  Future<String> getLanguage() async {
    await _initPrefs();
    return _prefs!.getString(_languageKey) ?? 'en-US';
  }

  /// Set language preference
  Future<void> setLanguage(String language) async {
    await _initPrefs();
    await _prefs!.setString(_languageKey, language);
  }

  /// Get current region (defaults to 'US')
  Future<String> getRegion() async {
    await _initPrefs();
    return _prefs!.getString(_regionKey) ?? 'US';
  }

  /// Set region preference
  Future<void> setRegion(String region) async {
    await _initPrefs();
    await _prefs!.setString(_regionKey, region);
  }

  /// Available languages for TMDB API
  static const Map<String, String> availableLanguages = {
    'en-US': 'English (US)',
    'es-ES': 'Spanish (Spain)',
    'fr-FR': 'French (France)',
    'de-DE': 'German (Germany)',
    'it-IT': 'Italian (Italy)',
    'pt-BR': 'Portuguese (Brazil)',
    'ja-JP': 'Japanese (Japan)',
    'ko-KR': 'Korean (South Korea)',
    'zh-CN': 'Chinese (Simplified)',
    'ru-RU': 'Russian (Russia)',
    'ar-SA': 'Arabic (Saudi Arabia)',
    'hi-IN': 'Hindi (India)',
  };

  /// Available regions for TMDB API
  static const Map<String, String> availableRegions = {
    'US': 'United States',
    'GB': 'United Kingdom',
    'CA': 'Canada',
    'AU': 'Australia',
    'DE': 'Germany',
    'FR': 'France',
    'ES': 'Spain',
    'IT': 'Italy',
    'JP': 'Japan',
    'KR': 'South Korea',
    'CN': 'China',
    'IN': 'India',
    'BR': 'Brazil',
    'MX': 'Mexico',
    'RU': 'Russia',
    'SA': 'Saudi Arabia',
  };
}