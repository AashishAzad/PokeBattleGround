import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/higher_or_lower_api.dart';
import '../../data/higher_or_lower_api_provider.dart';
import 'higher_or_lower_game_state.dart';

/// Owns all game logic for one Higher or Lower session: starting a game,
/// submitting guesses, and deciding state transitions. Widgets never call
/// HigherOrLowerApi directly — they call methods here and watch the state.
class HigherOrLowerGameNotifier extends StateNotifier<HigherOrLowerGameState> {
  final HigherOrLowerApi _api;

  HigherOrLowerGameNotifier(this._api) : super(const HigherOrLowerGameState());

  Future<void> startGame() async {
    state = state.copyWith(
      status: HigherOrLowerStatus.loading,
      clearError: true,
    );
    try {
      final result = await _api.startGame();
      state = HigherOrLowerGameState(
        status: HigherOrLowerStatus.playing,
        sessionId: result.sessionId,
        statKey: result.statKey,
        currentPokemon: result.pokemon,
        streak: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: HigherOrLowerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> submitGuess(String guess) async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;

    state = state.copyWith(status: HigherOrLowerStatus.loading);
    try {
      final result = await _api.submitGuess(
        sessionId: sessionId,
        guess: guess,
      );

      state = state.copyWith(
        status: result.correct
            ? HigherOrLowerStatus.playing
            : HigherOrLowerStatus.gameOver,
        currentPokemon: result.revealedPokemon,
        streak: result.resultingStreak,
      );
    } catch (e) {
      state = state.copyWith(
        status: HigherOrLowerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

/// `.family` keyed by the user's id so each signed-in user gets their own
/// independent game state (log out and in as someone else = fresh state).
/// The key is only for scoping — the notifier itself never needs it, since
/// the backend knows who is playing from the token.
final higherOrLowerGameProvider =
    StateNotifierProvider.family<
      HigherOrLowerGameNotifier,
      HigherOrLowerGameState,
      String
    >((ref, userId) {
      final api = ref.watch(higherOrLowerApiProvider);
      return HigherOrLowerGameNotifier(api);
    });
