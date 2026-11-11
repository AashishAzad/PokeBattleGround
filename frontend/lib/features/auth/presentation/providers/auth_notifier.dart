import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/auth_token_storage_provider.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../data/auth_api.dart';
import '../../data/auth_api_provider.dart';
import '../../data/models/auth_session.dart';
import 'auth_state.dart';

/// Owns the app's signed-in/signed-out state. Everything else that needs
/// to know "who is the user" (currentUserProvider, the AuthGate, the home
/// screen) derives from this one notifier rather than keeping its own copy.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _api;
  final AuthTokenStorage _tokenStorage;

  AuthNotifier(this._api, this._tokenStorage) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await _tokenStorage.read();
    if (token == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _api.getMe();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // The saved token is expired or invalid — discard it so we land on
        // the login screen cleanly instead of retrying a dead token forever.
        await _tokenStorage.delete();
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        // Network trouble or a server error is NOT proof the token is bad,
        // so keep it (the user shouldn't be logged out just because their
        // connection dropped) and let them retry from the login screen.
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        );
      }
    }
  }

  Future<void> login({required String username, required String password}) {
    return _authenticate(
      () => _api.login(username: username, password: password),
    );
  }

  Future<void> register({
    required String username,
    required String password,
  }) {
    return _authenticate(
      () => _api.register(username: username, password: password),
    );
  }

  Future<void> logout() async {
    await _tokenStorage.delete();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _authenticate(Future<AuthSession> Function() action) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final session = await action();
      await _tokenStorage.write(session.accessToken);
      state = AuthState(status: AuthStatus.authenticated, user: session.user);
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    ref.watch(authApiProvider),
    ref.watch(authTokenStorageProvider),
  );
});
