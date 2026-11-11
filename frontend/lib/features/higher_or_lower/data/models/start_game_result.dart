import 'higher_or_lower_pokemon.dart';

/// Response shape from POST /higher-or-lower/start.
class StartGameResult {
  final String sessionId;
  final String statKey;
  final HigherOrLowerPokemon pokemon;

  const StartGameResult({
    required this.sessionId,
    required this.statKey,
    required this.pokemon,
  });

  factory StartGameResult.fromJson(Map<String, dynamic> json) {
    return StartGameResult(
      sessionId: json['sessionId'] as String,
      statKey: json['statKey'] as String,
      pokemon: HigherOrLowerPokemon.fromJson(
        json['pokemon'] as Map<String, dynamic>,
      ),
    );
  }
}
