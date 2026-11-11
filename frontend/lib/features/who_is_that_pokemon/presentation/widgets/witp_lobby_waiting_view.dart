import 'package:flutter/material.dart';

import '../../data/models/witp_lobby_player.dart';

class WitpLobbyWaitingView extends StatelessWidget {
  final List<WitpLobbyPlayer> players;

  const WitpLobbyWaitingView({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Who Is That Pokémon?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Waiting for players (2-4 needed)...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        ...players.map(
          (p) => ListTile(
            leading: const Icon(Icons.person),
            title: Text(p.username),
          ),
        ),
      ],
    );
  }
}
