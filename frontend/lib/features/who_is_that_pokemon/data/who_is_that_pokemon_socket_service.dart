import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as socket_io;

import '../../../core/config/app_config.dart';
import '../../../core/storage/auth_token_storage.dart';
import 'models/correct_guess.dart';
import 'models/guess_result.dart';
import 'models/match_end.dart';
import 'models/round_end.dart';
import 'models/round_start.dart';
import 'models/witp_lobby_player.dart';

/// Thin wrapper around a single Socket.IO connection for Who Is That
/// Pokémon, mirroring TypeClashSocketService: the token goes in the
/// handshake, widgets only ever see typed streams, and identity is never
/// sent again after connecting.
class WhoIsThatPokemonSocketService {
  final AuthTokenStorage _tokenStorage;

  socket_io.Socket? _socket;
  bool _disposed = false;

  // The socket is created only after the (async) token read, so emitting
  // methods wait on this first rather than no-op against a null socket.
  final Completer<void> _ready = Completer<void>();

  WhoIsThatPokemonSocketService(this._tokenStorage);

  final _lobbyUpdateController =
      StreamController<List<WitpLobbyPlayer>>.broadcast();
  final _roundStartController = StreamController<RoundStart>.broadcast();
  final _guessResultController = StreamController<GuessResult>.broadcast();
  final _correctGuessController = StreamController<CorrectGuess>.broadcast();
  final _roundEndController = StreamController<RoundEnd>.broadcast();
  final _matchEndController = StreamController<MatchEnd>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<List<WitpLobbyPlayer>> get lobbyUpdates =>
      _lobbyUpdateController.stream;
  Stream<RoundStart> get roundStart => _roundStartController.stream;
  Stream<GuessResult> get guessResult => _guessResultController.stream;
  Stream<CorrectGuess> get correctGuess => _correctGuessController.stream;
  Stream<RoundEnd> get roundEnd => _roundEndController.stream;
  Stream<MatchEnd> get matchEnd => _matchEndController.stream;
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

    _socket!.on('whoIsThat:lobbyUpdate', (data) {
      final players = (data['players'] as List)
          .map((p) => WitpLobbyPlayer.fromJson(p as Map<String, dynamic>))
          .toList();
      _lobbyUpdateController.add(players);
    });

    _socket!.on('whoIsThat:roundStart', (data) {
      _roundStartController.add(
        RoundStart.fromJson(data as Map<String, dynamic>),
      );
    });

    _socket!.on('whoIsThat:guessResult', (data) {
      _guessResultController.add(
        GuessResult.fromJson(data as Map<String, dynamic>),
      );
    });

    _socket!.on('whoIsThat:correctGuess', (data) {
      _correctGuessController.add(
        CorrectGuess.fromJson(data as Map<String, dynamic>),
      );
    });

    _socket!.on('whoIsThat:roundEnd', (data) {
      _roundEndController.add(RoundEnd.fromJson(data as Map<String, dynamic>));
    });

    _socket!.on('whoIsThat:matchEnd', (data) {
      _matchEndController.add(MatchEnd.fromJson(data as Map<String, dynamic>));
    });

    _socket!.on('whoIsThat:error', (data) {
      final message =
          (data as Map<String, dynamic>)['message'] as String? ??
          'Unknown error';
      _emitError(message);
    });

    // 'io server disconnect' = the SERVER ended the connection, which is
    // what happens when our token is missing, expired, or rejected.
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

  /// No arguments: the server knows who we are from the handshake token.
  Future<void> joinLobby() async {
    await _ready.future;
    _socket?.emit('whoIsThat:joinLobby');
  }

  void submitGuess(String guess) {
    _socket?.emit('whoIsThat:guess', {'guess': guess});
  }

  void dispose() {
    _disposed = true;
    _socket?.dispose();
    _socket = null;
    _lobbyUpdateController.close();
    _roundStartController.close();
    _guessResultController.close();
    _correctGuessController.close();
    _roundEndController.close();
    _matchEndController.close();
    _errorController.close();
  }
}
