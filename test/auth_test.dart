import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick_finder/core/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should create guest session with valid token', () async {
      final authService = AuthService.instance;
      
      final token = await authService.createGuestSession();
      
      expect(token, isNotNull);
      expect(token, startsWith('guest_'));
      expect(token.length, greaterThan(20));
    });

    test('should store guest session data correctly', () async {
      final authService = AuthService.instance;
      
      await authService.createGuestSession();
      
      final isAuthenticated = await authService.isAuthenticated();
      final isGuest = await authService.isGuest();
      final token = await authService.getToken();
      final userId = await authService.getUserId();
      
      expect(isAuthenticated, isTrue);
      expect(isGuest, isTrue);
      expect(token, isNotNull);
      expect(userId, isNotNull);
      expect(userId, startsWith('guest_'));
    });

    test('should clear auth data on logout', () async {
      final authService = AuthService.instance;
      
      // Create guest session
      await authService.createGuestSession();
      expect(await authService.isAuthenticated(), isTrue);
      
      // Logout
      await authService.logout();
      
      final isAuthenticated = await authService.isAuthenticated();
      final isGuest = await authService.isGuest();
      final token = await authService.getToken();
      final userId = await authService.getUserId();
      
      expect(isAuthenticated, isFalse);
      expect(isGuest, isFalse);
      expect(token, isNull);
      expect(userId, isNull);
    });

    test('should return false for unauthenticated user', () async {
      final authService = AuthService.instance;
      
      final isAuthenticated = await authService.isAuthenticated();
      final isGuest = await authService.isGuest();
      
      expect(isAuthenticated, isFalse);
      expect(isGuest, isFalse);
    });
  });
}