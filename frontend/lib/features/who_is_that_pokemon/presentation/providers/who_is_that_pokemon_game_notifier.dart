import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import '../../../user/data/models/app_user.dart';
import '../../data/who_is_that_pokemon_socket_provider.dart';
import '../../data/who_is_that_pokemon_socket_service.dart';
import 'who_is_that_pokemon_game_state.dart';

class WhoIsThatPokemonGameNotifier extends StateNotifier<WitpGameState> {
  final WhoIsThatPokemonSocketService _socketService;

  late final StreamSubscription _lobbySub;
  late final StreamSubscription _roundStartSub;
  late final StreamSubscription _guessResultSub;
  late final StreamSubscription _correctGuessSub;
  late final StreamSubscription _roundEndSub;
  late final StreamSubscription _matchEndSub;
  late final StreamSubscription _errorSub;

  WhoIsThatPokemonGameNotifier(this._socketService)
    : super(const WitpGameState()) {
    _lobbySub = _socketService.lobbyUpdates.listen((players) {
      state = state.copyWith(phase: WitpPhase.inLobby, lobbyPlayers: players);
    });

    _roundStartSub = _socketService.roundStart.listen((round) {
      state = state.copyWith(
        phase: WitpPhase.roundActive,
        currentRound: round,
        hasGuessedCorrectly: false,
        recentCorrectGuesses: [],
        clearMyRoundScore: true,
      );
    });

    _guessResultSub = _socketService.guessResult.listen((result) {
      if (result.correct) {
        state = state.copyWith(
          hasGuessedCorrectly: true,
          myRoundScore: result.score,
        );
      }
    });

    _correctGuessSub = _socketService.correctGuess.listen((guess) {
      state = state.copyWith(
        recentCorrectGuesses: [...state.recentCorrectGuesses, guess],
      );
    });

    _roundEndSub = _socketService.roundEnd.listen((end) {
      state = state.copyWith(phase: WitpPhase.roundEnded, lastRoundEnd: end);
    });

    _matchEndSub = _socketService.matchEnd.listen((match) {
      state = state.copyWith(
        phase: WitpPhase.matchEnded,
        finalScores: match.finalScores,
      );
    });

    _errorSub = _socketService.errors.listen((message) {
      state = state.copyWith(errorMessage: message);
    });
  }

  void joinLobby() {
    state = state.copyWith(phase: WitpPhase.inLobby, clearError: true);
    _socketService.joinLobby();
  }

  void submitGuess(String guess) {
    _socketService.submitGuess(guess);
  }

  /// Resets back to a fresh state and immediately rejoins the lobby — the
  /// backend clears its lobby and unlocks for new matches right after a
  /// match ends, so this is safe to call as soon as the player taps
  /// "Play Again".
  void playAgain() {
    state = const WitpGameState();
    joinLobby();
  }

  @override
  void dispose() {
    _lobbySub.cancel();
    _roundStartSub.cancel();
    _guessResultSub.cancel();
    _correctGuessSub.cancel();
    _roundEndSub.cancel();
    _matchEndSub.cancel();
    _errorSub.cancel();
    super.dispose();
  }
}

final whoIsThatPokemonGameProvider = StateNotifierProvider.autoDispose
    .family<WhoIsThatPokemonGameNotifier, WitpGameState, AppUser>((
      ref,
      user,
    ) {
      final socketService = ref.watch(whoIsThatPokemonSocketServiceProvider);
      // `user` only scopes the state per signed-in user; the server
      // identifies the player from the socket's token.
      return WhoIsThatPokemonGameNotifier(socketService);
    });
