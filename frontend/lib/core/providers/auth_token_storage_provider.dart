import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/auth_token_storage.dart';

final authTokenStorageProvider = Provider<AuthTokenStorage>(
  (ref) => const AuthTokenStorage(),
);
