import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isGuest;
  final String? token;
  final String? userId;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.isGuest = false,
    this.token,
    this.userId,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isGuest,
    String? token,
    String? userId,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isAuthenticated = await AuthService.instance.isAuthenticated();
      final isGuest = await AuthService.instance.isGuest();
      final token = await AuthService.instance.getToken();
      final userId = await AuthService.instance.getUserId();

      state = state.copyWith(
        isAuthenticated: isAuthenticated,
        isGuest: isGuest,
        token: token,
        userId: userId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> createGuestSession() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final token = await AuthService.instance.createGuestSession();
      final userId = await AuthService.instance.getUserId();
      
      state = state.copyWith(
        isAuthenticated: true,
        isGuest: true,
        token: token,
        userId: userId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final token = await AuthService.instance.login(email, password);
      if (token != null) {
        final userId = await AuthService.instance.getUserId();
        
        state = state.copyWith(
          isAuthenticated: true,
          isGuest: false,
          token: token,
          userId: userId,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
        throw Exception('Login failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    state = const AuthState();
  }

  void refreshAuthState() {
    _checkAuthStatus();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});