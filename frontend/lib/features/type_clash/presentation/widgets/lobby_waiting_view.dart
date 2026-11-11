import 'package:flutter/material.dart';

import '../../data/models/lobby_player.dart';

class LobbyWaitingView extends StatelessWidget {
  final String difficulty;
  final List<LobbyPlayer> players;

  const LobbyWaitingView({
    super.key,
    required this.difficulty,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_capitalize(difficulty)} Lobby',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Waiting for players to join...',
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
