import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_client_provider.dart';
import 'leaderboard_api.dart';

final leaderboardApiProvider = Provider<LeaderboardApi>((ref) {
  return LeaderboardApi(ref.watch(apiClientProvider));
});
