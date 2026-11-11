import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_token_storage_provider.dart';
import 'who_is_that_pokemon_socket_service.dart';

final whoIsThatPokemonSocketServiceProvider =
    Provider.autoDispose<WhoIsThatPokemonSocketService>((ref) {
      final service = WhoIsThatPokemonSocketService(
        ref.watch(authTokenStorageProvider),
      );
      service.connect();
      ref.onDispose(service.dispose);
      return service;
    });
