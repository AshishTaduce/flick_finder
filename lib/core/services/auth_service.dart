import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'tmdb_auth_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _isGuestKey = 'is_guest';
  static const String _userIdKey = 'user_id';
  static const String _sessionIdKey = 'session_id';
  static const String _accountIdKey = 'account_id';
  static const String _usernameKey = 'username';

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

  /// Login with TMDB credentials
  Future<Map<String, dynamic>> login(String username, String password) async {
    await _initPrefs();
    
    try {
      final result = await TmdbAuthService.instance.login(
        username: username,
        password: password,
      );
      
      final sessionId = result['session_id'];
      final accountDetails = result['account_details'];
      
      // Store authentication data
      await _prefs!.setString(_tokenKey, sessionId);
      await _prefs!.setString(_sessionIdKey, sessionId);
      await _prefs!.setBool(_isGuestKey, false);
      await _prefs!.setString(_userIdKey, accountDetails['id'].toString());
      await _prefs!.setString(_accountIdKey, accountDetails['id'].toString());
      await _prefs!.setString(_usernameKey, accountDetails['username']);
      
      return {
        'session_id': sessionId,
        'account_details': accountDetails,
      };
    } catch (e) {
      rethrow;
    }
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

  /// Get session ID (for TMDB authenticated users)
  Future<String?> getSessionId() async {
    await _initPrefs();
    return _prefs!.getString(_sessionIdKey);
  }

  /// Get account ID (for TMDB authenticated users)
  Future<String?> getAccountId() async {
    await _initPrefs();
    return _prefs!.getString(_accountIdKey);
  }

  /// Get username (for TMDB authenticated users)
  Future<String?> getUsername() async {
    await _initPrefs();
    return _prefs!.getString(_usernameKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout user
  Future<void> logout() async {
    await _initPrefs();
    
    // If user has a session ID, try to delete it from TMDB
    final sessionId = await getSessionId();
    if (sessionId != null && !await isGuest()) {
      try {
        await TmdbAuthService.instance.deleteSession(sessionId);
      } catch (e) {
        // Continue with logout even if API call fails
      }
    }
    
    // Clear all stored data
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_isGuestKey);
    await _prefs!.remove(_userIdKey);
    await _prefs!.remove(_sessionIdKey);
    await _prefs!.remove(_accountIdKey);
    await _prefs!.remove(_usernameKey);
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    await logout();
  }
}