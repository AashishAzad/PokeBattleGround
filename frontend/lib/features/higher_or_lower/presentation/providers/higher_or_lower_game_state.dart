import '../../data/models/higher_or_lower_pokemon.dart';

enum HigherOrLowerStatus { initial, loading, playing, gameOver, error }

/// Immutable state for one Higher or Lower game session. Only
/// HigherOrLowerGameNotifier ever constructs new instances of this —
/// widgets only ever read it via `ref.watch`, never mutate it directly.
class HigherOrLowerGameState {
  final HigherOrLowerStatus status;
  final String? sessionId;
  final String? statKey;
  final HigherOrLowerPokemon? currentPokemon;
  final int streak;
  final String? errorMessage;

  const HigherOrLowerGameState({
    this.status = HigherOrLowerStatus.initial,
    this.sessionId,
    this.statKey,
    this.currentPokemon,
    this.streak = 0,
    this.errorMessage,
  });

  HigherOrLowerGameState copyWith({
    HigherOrLowerStatus? status,
    String? sessionId,
    String? statKey,
    HigherOrLowerPokemon? currentPokemon,
    int? streak,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HigherOrLowerGameState(
      status: status ?? this.status,
      sessionId: sessionId ?? this.sessionId,
      statKey: statKey ?? this.statKey,
      currentPokemon: currentPokemon ?? this.currentPokemon,
      streak: streak ?? this.streak,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
