import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isGuest;
  final String? token;
  final String? userId;
  final String? sessionId;
  final String? accountId;
  final String? username;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.isGuest = false,
    this.token,
    this.userId,
    this.sessionId,
    this.accountId,
    this.username,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isGuest,
    String? token,
    String? userId,
    String? sessionId,
    String? accountId,
    String? username,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
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
      final sessionId = await AuthService.instance.getSessionId();
      final accountId = await AuthService.instance.getAccountId();
      final username = await AuthService.instance.getUsername();

      state = state.copyWith(
        isAuthenticated: isAuthenticated,
        isGuest: isGuest,
        token: token,
        userId: userId,
        sessionId: sessionId,
        accountId: accountId,
        username: username,
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

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await AuthService.instance.login(username, password);
      final sessionId = result['session_id'];
      
      final userId = await AuthService.instance.getUserId();
      final accountId = await AuthService.instance.getAccountId();
      final storedUsername = await AuthService.instance.getUsername();
      
      state = state.copyWith(
        isAuthenticated: true,
        isGuest: false,
        token: sessionId,
        userId: userId,
        sessionId: sessionId,
        accountId: accountId,
        username: storedUsername,
        isLoading: false,
      );
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