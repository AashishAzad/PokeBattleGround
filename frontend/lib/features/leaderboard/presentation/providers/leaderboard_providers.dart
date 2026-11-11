import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/leaderboard_api_provider.dart';
import '../../data/models/global_ranking_entry.dart';
import '../../data/models/leaderboard_entry.dart';

final globalRankingProvider =
    FutureProvider.autoDispose<List<GlobalRankingEntry>>((ref) async {
      final api = ref.watch(leaderboardApiProvider);
      return api.getGlobalRanking();
    });

final gameLeaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, String>((ref, gameType) async {
      final api = ref.watch(leaderboardApiProvider);
      return api.getLeaderboard(gameType);
    });
