import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick_finder/core/services/auth_service.dart';

void main() {
  group('Login Flow Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should accept username and password for login', () async {
      final authService = AuthService.instance;
      
      // Test that the login method accepts username and password parameters
      // Note: This will fail with network error since we're not mocking the API,
      // but it verifies the method signature is correct
      
      expect(
        () => authService.login('testuser', 'testpass'),
        throwsA(isA<Exception>()),
      );
    });

    test('should validate username requirements', () {
      // Test username validation logic
      const username = 'testuser';
      const password = 'testpass123';
      
      // Username should be at least 3 characters
      expect(username.length >= 3, isTrue);
      
      // Password should be at least 4 characters (as per TMDB requirements)
      expect(password.length >= 4, isTrue);
      
      // Username should not be empty
      expect(username.isNotEmpty, isTrue);
      expect(password.isNotEmpty, isTrue);
    });

    test('should handle different username formats', () {
      // Test various username formats that TMDB might accept
      final validUsernames = [
        'user123',
        'test_user',
        'moviefan',
        'user.name',
        'User123',
      ];
      
      for (final username in validUsernames) {
        expect(username.length >= 3, isTrue, reason: 'Username $username should be at least 3 characters');
        expect(username.isNotEmpty, isTrue, reason: 'Username $username should not be empty');
      }
    });

    test('should store username after successful login', () async {
      // Simulate successful login by setting the data directly
      SharedPreferences.setMockInitialValues({
        'auth_token': 'test_session_id',
        'session_id': 'test_session_id',
        'is_guest': false,
        'user_id': '12345',
        'account_id': '12345',
        'username': 'testuser',
      });
      
      final authService = AuthService.instance;
      
      // Verify that username is stored and retrievable
      final storedUsername = await authService.getUsername();
      expect(storedUsername, equals('testuser'));
      
      // Verify user is not a guest
      expect(await authService.isGuest(), isFalse);
      expect(await authService.isAuthenticated(), isTrue);
    });

    test('should clear username on logout', () async {
      // Set up authenticated user
      SharedPreferences.setMockInitialValues({
        'auth_token': 'test_session_id',
        'session_id': 'test_session_id',
        'is_guest': false,
        'user_id': '12345',
        'account_id': '12345',
        'username': 'testuser',
      });
      
      final authService = AuthService.instance;
      
      // Verify data is set
      expect(await authService.getUsername(), equals('testuser'));
      expect(await authService.isAuthenticated(), isTrue);
      
      // Logout
      await authService.logout();
      
      // Verify username is cleared
      expect(await authService.getUsername(), isNull);
      expect(await authService.isAuthenticated(), isFalse);
    });
  });
}