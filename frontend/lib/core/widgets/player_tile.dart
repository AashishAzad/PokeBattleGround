import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'glass_container.dart';

/// One player row on glass — shared by leaderboards, lobbies and match
/// results. Pass [rank] to show a numbered badge (top 3 get medal colors).
class PlayerTile extends StatelessWidget {
  final String username;
  final int? rank;
  final String? subtitle;
  final String? trailing;
  final bool highlight;

  const PlayerTile({
    super.key,
    required this.username,
    this.rank,
    this.subtitle,
    this.trailing,
    this.highlight = false,
  });

  static Color? medalColor(int rank) => switch (rank) {
    1 => AppColors.gold,
    2 => AppColors.silver,
    3 => AppColors.bronze,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final medal = rank != null ? medalColor(rank!) : null;
    final accent = medal ?? (highlight ? AppColors.electricYellow : null);

    return GlassContainer(
      blur: 0,
      shadows: const [],
      borderRadius: AppRadii.mdAll,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      borderColor: accent?.withValues(alpha: 0.6),
      gradient: accent != null
          ? LinearGradient(
              colors: [
                accent.withValues(alpha: 0.2),
                AppColors.glassFillSubtle,
              ],
            )
          : null,
      child: Row(
        children: [
          _Badge(rank: rank, username: username, medal: medal),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                color: medal ?? AppColors.electricYellow,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int? rank;
  final String username;
  final Color? medal;

  const _Badge({
    required this.rank,
    required this.username,
    required this.medal,
  });

  @override
  Widget build(BuildContext context) {
    final label = rank != null
        ? '$rank'
        : (username.isEmpty ? '?' : username[0].toUpperCase());
    final color = medal ?? AppColors.aquaBlue;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.55)],
        ),
        boxShadow: medal != null
            ? [BoxShadow(color: medal!.withValues(alpha: 0.5), blurRadius: 12)]
            : null,
      ),
      child: medal != null && rank == 1
          ? const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.textOnAccent,
              size: 22,
            )
          : Text(
              label,
              style: TextStyle(
                color: medal != null ? AppColors.textOnAccent : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
    );
  }
}
