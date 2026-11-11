import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_client_provider.dart';
import 'type_clash_rest_api.dart';

final typeClashRestApiProvider = Provider<TypeClashRestApi>((ref) {
  return TypeClashRestApi(ref.watch(apiClientProvider));
});
