import '../../../core/network/api_client.dart';
import 'models/bubble_battle_result.dart';

class TypeClashRestApi {
  final ApiClient _apiClient;

  TypeClashRestApi(this._apiClient);

  /// The player is identified by the bearer token, not by anything in the
  /// body — the backend rejects a body that tries to name a userId.
  Future<BubbleBattleResult> startSinglePlayer({
    required String difficulty,
    required String chosenType,
  }) async {
    final json = await _apiClient.post(
      '/type-clash/single-player/start',
      data: {'difficulty': difficulty, 'chosenType': chosenType},
    );
    return BubbleBattleResult.fromJson(json);
  }
}
