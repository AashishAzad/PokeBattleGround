import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'auth_token_storage_provider.dart';

/// Exposes one shared ApiClient instance app-wide via Riverpod, so every
/// feature's data layer reads this instead of constructing its own Dio
/// client (which would mean duplicated base URL/timeout/auth config).
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(authTokenStorageProvider)),
);
