import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../user/data/models/app_user.dart';
import '../../data/type_clash_socket_provider.dart';
import '../../data/type_clash_socket_service.dart';
import 'type_clash_game_state.dart';

/// Owns the entire Type Clash game flow for one player: joining a lobby,
/// reacting to other players, claiming a type, and playing through the
/// battle result. Widgets never touch TypeClashSocketService directly.
class TypeClashGameNotifier extends StateNotifier<TypeClashGameState> {
  final TypeClashSocketService _socketService;

  late final StreamSubscription _lobbySub;
  late final StreamSubscription _selectionStartedSub;
  late final StreamSubscription _typeClaimedSub;
  late final StreamSubscription _selectionCompleteSub;
  late final StreamSubscription _battleResultSub;
  late final StreamSubscription _errorSub;

  TypeClashGameNotifier(this._socketService)
    : super(const TypeClashGameState()) {
    _lobbySub = _socketService.lobbyUpdates.listen((players) {
      state = state.copyWith(lobbyPlayers: players);
    });

    _selectionStartedSub = _socketService.typeSelectionStarted.listen((
      event,
    ) {
      state = state.copyWith(
        phase: TypeClashPhase.selectingType,
        availableTypes: event.availableTypes,
        selectionSeconds: event.selectionSeconds,
        claimedTypeUsernames: {},
      );
    });

    _typeClaimedSub = _socketService.typeClaimed.listen((event) {
      state = state.copyWith(
        claimedTypeUsernames: {
          ...state.claimedTypeUsernames,
          event.type: event.username,
        },
      );
    });

    _selectionCompleteSub = _socketService.typeSelectionComplete.listen((
      assignments,
    ) {
      state = state.copyWith(
        phase: TypeClashPhase.waitingForBattle,
        finalAssignments: assignments,
      );
    });

    _battleResultSub = _socketService.battleResult.listen((result) {
      state = state.copyWith(
        phase: TypeClashPhase.battleReady,
        battleResult: result,
      );
    });

    _errorSub = _socketService.errors.listen((message) {
      state = state.copyWith(errorMessage: message);
    });
  }

  void joinLobby(String difficulty) {
    state = state.copyWith(
      phase: TypeClashPhase.inLobby,
      difficulty: difficulty,
      clearError: true,
    );
    _socketService.joinLobby(difficulty: difficulty);
  }

  void selectType(String type) {
    final difficulty = state.difficulty;
    if (difficulty == null) return;
    state = state.copyWith(mySelectedType: type);
    _socketService.selectType(difficulty: difficulty, type: type);
  }

  /// Resets back to the difficulty-choosing phase so the player can start
  /// a fresh lobby without leaving the screen or reconnecting the socket.
  void playAgain() {
    state = const TypeClashGameState();
  }

  @override
  void dispose() {
    _lobbySub.cancel();
    _selectionStartedSub.cancel();
    _typeClaimedSub.cancel();
    _selectionCompleteSub.cancel();
    _battleResultSub.cancel();
    _errorSub.cancel();
    super.dispose();
  }
}

/// Keyed by AppUser so each signed-in user gets independent game state.
/// The key is only for scoping — the notifier doesn't need the user, since
/// the server identifies the player from the socket's token.
final typeClashGameProvider = StateNotifierProvider.autoDispose
    .family<TypeClashGameNotifier, TypeClashGameState, AppUser>((ref, user) {
      final socketService = ref.watch(typeClashSocketServiceProvider);
      return TypeClashGameNotifier(socketService);
    });
