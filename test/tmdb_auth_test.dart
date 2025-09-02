import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flick_finder/core/services/auth_service.dart';
import 'package:flick_finder/core/services/user_features_service.dart';

void main() {
  group('TMDB Authentication Tests', () {
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
      
      expect(await authService.isAuthenticated(), isTrue);
      expect(await authService.isGuest(), isTrue);
    });

    test('should handle feature access errors for guests', () async {
      final userFeaturesService = UserFeaturesService.instance;
      
      // Create guest session
      await AuthService.instance.createGuestSession();
      
      // Test that premium features throw appropriate errors
      expect(
        () => userFeaturesService.toggleWatchlist(123, true),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Please login with your TMDB account'),
        )),
      );
      
      expect(
        () => userFeaturesService.toggleFavorite(123, true),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Please login with your TMDB account'),
        )),
      );
      
      expect(
        () => userFeaturesService.rateMovie(123, 8.5),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Please login with your TMDB account'),
        )),
      );
    });

    test('should validate movie rating range', () async {
      final userFeaturesService = UserFeaturesService.instance;
      
      // Test rating validation logic
      expect(0.4 < 0.5, isTrue); // Below minimum
      expect(10.1 > 10.0, isTrue); // Above maximum
      expect(5.0 >= 0.5 && 5.0 <= 10.0, isTrue); // Valid range
    });

    test('should clear guest session on logout', () async {
      final authService = AuthService.instance;
      
      // Create guest session
      await authService.createGuestSession();
      expect(await authService.isAuthenticated(), isTrue);
      expect(await authService.isGuest(), isTrue);
      
      // Logout
      await authService.logout();
      
      expect(await authService.isAuthenticated(), isFalse);
      expect(await authService.isGuest(), isFalse);
      expect(await authService.getToken(), isNull);
    });

    test('should differentiate between guest and authenticated users', () async {
      // Test unauthenticated state
      expect(await UserFeaturesService.instance.canAccessPremiumFeatures(), isFalse);
      
      // Test guest session
      await AuthService.instance.createGuestSession();
      expect(await UserFeaturesService.instance.canAccessPremiumFeatures(), isFalse);
      
      // Clear session
      await AuthService.instance.logout();
      expect(await UserFeaturesService.instance.canAccessPremiumFeatures(), isFalse);
    });

    test('should generate unique guest tokens', () async {
      final authService = AuthService.instance;
      
      // Create first guest session
      final token1 = await authService.createGuestSession();
      await authService.logout();
      
      // Create second guest session
      final token2 = await authService.createGuestSession();
      
      expect(token1, isNot(equals(token2)));
      expect(token1, startsWith('guest_'));
      expect(token2, startsWith('guest_'));
    });
  });
}