import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../../../core/config/app_config.dart';
import '../../../core/storage/auth_token_storage.dart';
import 'models/bubble_battle_result.dart';
import 'models/lobby_player.dart';
import 'models/type_claimed.dart';
import 'models/type_selection_started.dart';

/// Thin wrapper around a single Socket.IO connection for Type Clash.
/// Exposes each server event as a typed Stream so widgets never touch
/// socket.on() or raw JSON.
///
/// The connection authenticates by sending the saved access token in the
/// Socket.IO handshake; the server disconnects any socket without a valid
/// one. After that, identity is never sent again — the server remembers who
/// this socket belongs to.
class TypeClashSocketService {
  final AuthTokenStorage _tokenStorage;

  socket_io.Socket? _socket;
  bool _disposed = false;

  // Reading the token is async, so the socket doesn't exist the instant
  // this service is constructed. Emitting methods wait on this first so a
  // fast "join lobby" can't silently no-op against a null socket.
  final Completer<void> _ready = Completer<void>();

  TypeClashSocketService(this._tokenStorage);

  final _lobbyUpdateController =
      StreamController<List<LobbyPlayer>>.broadcast();
  final _typeSelectionStartedController =
      StreamController<TypeSelectionStarted>.broadcast();
  final _typeClaimedController = StreamController<TypeClaimed>.broadcast();
  final _typeSelectionCompleteController =
      StreamController<Map<String, LobbyPlayer>>.broadcast();
  final _battleResultController =
      StreamController<BubbleBattleResult>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<List<LobbyPlayer>> get lobbyUpdates => _lobbyUpdateController.stream;
  Stream<TypeSelectionStarted> get typeSelectionStarted =>
      _typeSelectionStartedController.stream;
  Stream<TypeClaimed> get typeClaimed => _typeClaimedController.stream;
  Stream<Map<String, LobbyPlayer>> get typeSelectionComplete =>
      _typeSelectionCompleteController.stream;
  Stream<BubbleBattleResult> get battleResult =>
      _battleResultController.stream;
  Stream<String> get errors => _errorController.stream;

  Future<void> connect() async {
    if (_socket != null || _disposed) return;

    final token = await _tokenStorage.read();
    if (_disposed) return; // disposed while we were reading the token

    _socket = socket_io.io(
      AppConfig.apiBaseUrl,
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.on('typeClash:lobbyUpdate', (data) {
      final players = (data['players'] as List)
          .map((p) => LobbyPlayer.fromJson(p as Map<String, dynamic>))
          .toList();
      _lobbyUpdateController.add(players);
    });

    _socket!.on('typeClash:typeSelectionStarted', (data) {
      _typeSelectionStartedController.add(
        TypeSelectionStarted.fromJson(data as Map<String, dynamic>),
      );
    });

    _socket!.on('typeClash:typeClaimed', (data) {
      _typeClaimedController.add(
        TypeClaimed.fromJson(data as Map<String, dynamic>),
      );
    });

    _socket!.on('typeClash:typeSelectionComplete', (data) {
      final assignmentsJson =
          (data as Map<String, dynamic>)['assignments']
              as Map<String, dynamic>;
      final assignments = assignmentsJson.map(
        (type, player) => MapEntry(
          type,
          LobbyPlayer.fromJson(player as Map<String, dynamic>),
        ),
      );
      _typeSelectionCompleteController.add(assignments);
    });

    _socket!.on('typeClash:battleResult', (data) {
      _battleResultController.add(
        BubbleBattleResult.fromJson(data as Map<String, dynamic>),
      );
    });

    _socket!.on('typeClash:error', (data) {
      final message =
          (data as Map<String, dynamic>)['message'] as String? ??
          'Unknown error';
      _emitError(message);
    });

    // 'io server disconnect' means the SERVER ended the connection — what
    // happens when our token is missing, expired, or rejected. Without
    // surfacing it, the UI would just sit there waiting forever.
    _socket!.onDisconnect((reason) {
      if (reason == 'io server disconnect') {
        _emitError(
          'The server closed your connection. Try logging out and back in.',
        );
      }
    });

    _socket!.connect();
    _ready.complete();
  }

  void _emitError(String message) {
    if (!_errorController.isClosed) _errorController.add(message);
  }

  /// Only the difficulty is sent — the server already knows who we are from
  /// the token presented at connection time.
  Future<void> joinLobby({required String difficulty}) async {
    await _ready.future;
    _socket?.emit('typeClash:joinLobby', {'difficulty': difficulty});
  }

  Future<void> selectType({
    required String difficulty,
    required String type,
  }) async {
    await _ready.future;
    _socket?.emit('typeClash:selectType', {
      'difficulty': difficulty,
      'type': type,
    });
  }

  void dispose() {
    _disposed = true;
    _socket?.dispose();
    _socket = null;
    _lobbyUpdateController.close();
    _typeSelectionStartedController.close();
    _typeClaimedController.close();
    _typeSelectionCompleteController.close();
    _battleResultController.close();
    _errorController.close();
  }
}
