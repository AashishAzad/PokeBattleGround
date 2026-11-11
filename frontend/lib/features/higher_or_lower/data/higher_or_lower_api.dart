import '../../../core/network/api_client.dart';
import 'models/guess_result.dart';
import 'models/start_game_result.dart';

/// All HTTP calls for the Higher or Lower game live here. The presentation
/// layer never calls ApiClient directly — this is the only place that knows
/// this game's endpoints and payload shapes.
///
/// Note there is no userId anywhere: the backend identifies the player from
/// the bearer token ApiClient attaches to every request.
class HigherOrLowerApi {
  final ApiClient _apiClient;

  HigherOrLowerApi(this._apiClient);

  Future<StartGameResult> startGame() async {
    final json = await _apiClient.post('/higher-or-lower/start');
    return StartGameResult.fromJson(json);
  }

  Future<GuessResult> submitGuess({
    required String sessionId,
    required String guess, // 'higher' or 'lower'
  }) async {
    final json = await _apiClient.post(
      '/higher-or-lower/guess',
      data: {'sessionId': sessionId, 'guess': guess},
    );
    return GuessResult.fromJson(json);
  }
}
