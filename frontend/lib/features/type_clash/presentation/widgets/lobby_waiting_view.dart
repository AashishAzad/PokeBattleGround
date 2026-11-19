import 'package:flutter/material.dart';

import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/widgets.dart';
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
    return LobbyWaitingPanel(
      title: '${difficulty.capitalized} Lobby',
      subtitle: 'Waiting for players to join...',
      usernames: [for (final p in players) p.username],
    );
  }
}
