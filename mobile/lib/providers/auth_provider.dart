// lib/providers/auth_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/network_providers.dart';
import '../core/utils/result.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

// State class
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isCheckingAuth;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.isCheckingAuth = true,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    bool? isCheckingAuth,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isCheckingAuth: isCheckingAuth ?? this.isCheckingAuth,
    );
  }
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  late final StreamSubscription<void> _unauthorizedSubscription;

  AuthNotifier(this._repository, ApiClient apiClient)
    : super(const AuthState()) {
    _unauthorizedSubscription = apiClient.unauthorizedEvents.listen((_) {
      state = const AuthState(isAuthenticated: false, isCheckingAuth: false);
    });
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final loggedIn = await _repository.isLoggedIn();
    if (loggedIn) {
      final result = await _repository.getProfile();
      result.when(
        success: (user) => state = AuthState(
          user: user,
          isAuthenticated: true,
          isCheckingAuth: false,
        ),
        error: (_) => state = const AuthState(
          isAuthenticated: false,
          isCheckingAuth: false,
        ),
      );
    } else {
      state = const AuthState(isAuthenticated: false, isCheckingAuth: false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.login(email: email, password: password);

    return result.when(
      success: (user) {
        state = AuthState(
          user: user,
          isAuthenticated: true,
          isCheckingAuth: false,
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    return result.when(
      success: (user) {
        state = AuthState(
          user: user,
          isAuthenticated: true,
          isCheckingAuth: false,
        );
        return true;
      },
      error: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = const AuthState(isAuthenticated: false, isCheckingAuth: false);
  }

  @override
  void dispose() {
    _unauthorizedSubscription.cancel();
    super.dispose();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(apiClientProvider),
  );
});
