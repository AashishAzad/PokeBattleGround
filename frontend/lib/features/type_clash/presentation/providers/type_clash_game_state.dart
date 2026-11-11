import '../../data/models/bubble_battle_result.dart';
import '../../data/models/lobby_player.dart';

enum TypeClashPhase {
  choosingDifficulty,
  inLobby,
  selectingType,
  waitingForBattle,
  battleReady,
}

class TypeClashGameState {
  final TypeClashPhase phase;
  final String? difficulty;
  final List<LobbyPlayer> lobbyPlayers;
  final List<String> availableTypes;
  final int selectionSeconds;
  final Map<String, String> claimedTypeUsernames;
  final String? mySelectedType;
  final Map<String, LobbyPlayer>? finalAssignments;
  final BubbleBattleResult? battleResult;
  final String? errorMessage;

  const TypeClashGameState({
    this.phase = TypeClashPhase.choosingDifficulty,
    this.difficulty,
    this.lobbyPlayers = const [],
    this.availableTypes = const [],
    this.selectionSeconds = 0,
    this.claimedTypeUsernames = const {},
    this.mySelectedType,
    this.finalAssignments,
    this.battleResult,
    this.errorMessage,
  });

  TypeClashGameState copyWith({
    TypeClashPhase? phase,
    String? difficulty,
    List<LobbyPlayer>? lobbyPlayers,
    List<String>? availableTypes,
    int? selectionSeconds,
    Map<String, String>? claimedTypeUsernames,
    String? mySelectedType,
    Map<String, LobbyPlayer>? finalAssignments,
    BubbleBattleResult? battleResult,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TypeClashGameState(
      phase: phase ?? this.phase,
      difficulty: difficulty ?? this.difficulty,
      lobbyPlayers: lobbyPlayers ?? this.lobbyPlayers,
      availableTypes: availableTypes ?? this.availableTypes,
      selectionSeconds: selectionSeconds ?? this.selectionSeconds,
      claimedTypeUsernames: claimedTypeUsernames ?? this.claimedTypeUsernames,
      mySelectedType: mySelectedType ?? this.mySelectedType,
      finalAssignments: finalAssignments ?? this.finalAssignments,
      battleResult: battleResult ?? this.battleResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
