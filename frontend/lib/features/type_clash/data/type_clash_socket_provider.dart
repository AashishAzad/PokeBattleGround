import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_token_storage_provider.dart';
import 'type_clash_socket_service.dart';

/// One shared socket connection while the player is on a Type Clash
/// screen. `.autoDispose` closes the connection once nothing is watching
/// it anymore (e.g. the player navigates away) — we never want a lingering
/// open socket after leaving the game.
final typeClashSocketServiceProvider =
    Provider.autoDispose<TypeClashSocketService>((ref) {
      final service = TypeClashSocketService(
        ref.watch(authTokenStorageProvider),
      );
      service.connect();
      ref.onDispose(service.dispose);
      return service;
    });
