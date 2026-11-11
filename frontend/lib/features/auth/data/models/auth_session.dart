import '../../../user/data/models/app_user.dart';

/// Response shape from POST /auth/login and POST /auth/register.
class AuthSession {
  final String accessToken;
  final AppUser user;

  const AuthSession({required this.accessToken, required this.user});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
