import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the JWT access token in the platform's secure storage (Android
/// Keystore-backed encryption, iOS Keychain, encrypted storage on web) —
/// NOT in SharedPreferences, which is plain text and wrong for credentials.
/// Wrapped in its own class so the rest of the app never imports the
/// plugin directly, and swapping the storage mechanism later touches one file.
class AuthTokenStorage {
  static const _tokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  const AuthTokenStorage([this._storage = const FlutterSecureStorage()]);

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> delete() => _storage.delete(key: _tokenKey);
}
