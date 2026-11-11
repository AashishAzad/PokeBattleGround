import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_client_provider.dart';
import 'higher_or_lower_api.dart';

final higherOrLowerApiProvider = Provider<HigherOrLowerApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HigherOrLowerApi(apiClient);
});
