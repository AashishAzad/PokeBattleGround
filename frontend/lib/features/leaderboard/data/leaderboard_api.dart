import '../../../core/network/api_client.dart';
import 'models/global_ranking_entry.dart';
import 'models/leaderboard_entry.dart';

class LeaderboardApi {
  final ApiClient _apiClient;

  LeaderboardApi(this._apiClient);

  Future<List<GlobalRankingEntry>> getGlobalRanking({int limit = 50}) async {
    final json = await _apiClient.getList(
      '/game-scores/global-ranking',
      queryParameters: {'limit': limit},
    );
    return json
        .map((e) => GlobalRankingEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaderboardEntry>> getLeaderboard(
    String gameType, {
    int limit = 20,
  }) async {
    final json = await _apiClient.getList(
      '/game-scores/leaderboard/$gameType',
      queryParameters: {'limit': limit},
    );
    return json
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
