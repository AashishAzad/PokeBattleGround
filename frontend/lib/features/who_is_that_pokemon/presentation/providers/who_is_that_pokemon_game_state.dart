import '../../data/models/correct_guess.dart';
import '../../data/models/match_end.dart';
import '../../data/models/round_end.dart';
import '../../data/models/round_start.dart';
import '../../data/models/witp_lobby_player.dart';

enum WitpPhase {
  choosingToJoin,
  inLobby,
  roundActive,
  roundEnded,
  matchEnded,
  error,
}

class WitpGameState {
  final WitpPhase phase;
  final List<WitpLobbyPlayer> lobbyPlayers;
  final RoundStart? currentRound;
  final bool hasGuessedCorrectly;
  final int? myRoundScore;
  final List<CorrectGuess> recentCorrectGuesses;
  final RoundEnd? lastRoundEnd;
  final List<PlayerScore>? finalScores;
  final String? errorMessage;

  const WitpGameState({
    this.phase = WitpPhase.choosingToJoin,
    this.lobbyPlayers = const [],
    this.currentRound,
    this.hasGuessedCorrectly = false,
    this.myRoundScore,
    this.recentCorrectGuesses = const [],
    this.lastRoundEnd,
    this.finalScores,
    this.errorMessage,
  });

  WitpGameState copyWith({
    WitpPhase? phase,
    List<WitpLobbyPlayer>? lobbyPlayers,
    RoundStart? currentRound,
    bool? hasGuessedCorrectly,
    int? myRoundScore,
    List<CorrectGuess>? recentCorrectGuesses,
    RoundEnd? lastRoundEnd,
    List<PlayerScore>? finalScores,
    String? errorMessage,
    bool clearError = false,
    bool clearMyRoundScore = false,
  }) {
    return WitpGameState(
      phase: phase ?? this.phase,
      lobbyPlayers: lobbyPlayers ?? this.lobbyPlayers,
      currentRound: currentRound ?? this.currentRound,
      hasGuessedCorrectly: hasGuessedCorrectly ?? this.hasGuessedCorrectly,
      myRoundScore: clearMyRoundScore
          ? null
          : (myRoundScore ?? this.myRoundScore),
      recentCorrectGuesses: recentCorrectGuesses ?? this.recentCorrectGuesses,
      lastRoundEnd: lastRoundEnd ?? this.lastRoundEnd,
      finalScores: finalScores ?? this.finalScores,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
