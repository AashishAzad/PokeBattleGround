import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/models/witp_lobby_player.dart';

class WitpLobbyWaitingView extends StatelessWidget {
  final List<WitpLobbyPlayer> players;

  const WitpLobbyWaitingView({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return LobbyWaitingPanel(
      title: 'Who Is That Pokémon?',
      subtitle: 'Waiting for players (2-4 needed)...',
      usernames: [for (final p in players) p.username],
    );
  }
}
