import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _isGuestKey = 'is_guest';
  static const String _userIdKey = 'user_id';

  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Generate a guest session token
  String _generateGuestToken() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = List.generate(16, (index) => 
        random.nextInt(36).toRadixString(36)).join();
    return 'guest_${timestamp}_$randomString';
  }

  /// Create a guest session
  Future<String> createGuestSession() async {
    await _initPrefs();
    final token = _generateGuestToken();
    final userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    
    await _prefs!.setString(_tokenKey, token);
    await _prefs!.setBool(_isGuestKey, true);
    await _prefs!.setString(_userIdKey, userId);
    
    return token;
  }

  /// Login with credentials (placeholder for future implementation)
  Future<String?> login(String email, String password) async {
    await _initPrefs();
    // TODO: Implement actual login API call
    // For now, return null to indicate login not implemented
    return null;
  }

  /// Get current auth token
  Future<String?> getToken() async {
    await _initPrefs();
    return _prefs!.getString(_tokenKey);
  }

  /// Check if user is guest
  Future<bool> isGuest() async {
    await _initPrefs();
    return _prefs!.getBool(_isGuestKey) ?? false;
  }

  /// Get user ID
  Future<String?> getUserId() async {
    await _initPrefs();
    return _prefs!.getString(_userIdKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout user
  Future<void> logout() async {
    await _initPrefs();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_isGuestKey);
    await _prefs!.remove(_userIdKey);
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    await logout();
  }
}