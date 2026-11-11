import '../../../core/network/api_client.dart';
import '../../user/data/models/app_user.dart';
import 'models/auth_session.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final json = await _apiClient.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return AuthSession.fromJson(json);
  }

  Future<AuthSession> register({
    required String username,
    required String password,
  }) async {
    final json = await _apiClient.post(
      '/auth/register',
      data: {'username': username, 'password': password},
    );
    return AuthSession.fromJson(json);
  }

  /// Validates the saved token against the server and returns who it
  /// belongs to — used at app start to restore a session.
  Future<AppUser> getMe() async {
    final json = await _apiClient.get('/auth/me');
    return AppUser.fromJson(json);
  }
}
