import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import 'glass_container.dart';
import 'player_tile.dart';
import 'poke_ball.dart';

/// Shared "waiting for players" view for every multiplayer lobby.
class LobbyWaitingPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> usernames;

  const LobbyWaitingPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.usernames,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            const PokeBallLoader(size: 52),
            const SizedBox(height: AppSpacing.md),
            Text(subtitle, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('${usernames.length} in lobby', style: textTheme.bodySmall),
            if (usernames.isNotEmpty) const SizedBox(height: AppSpacing.md),
            for (final name in usernames)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: PlayerTile(username: name),
              ),
          ],
        ),
      ),
    );
  }
}
