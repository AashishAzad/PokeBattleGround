import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/match_end.dart';

class MatchEndView extends StatelessWidget {
  final List<PlayerScore> finalScores;
  final VoidCallback onPlayAgain;

  const MatchEndView({
    super.key,
    required this.finalScores,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...finalScores]..sort((a, b) => b.score.compareTo(a.score));

    return EntranceAnimation(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.gold,
                size: 56,
                shadows: [Shadow(color: AppColors.gold, blurRadius: 24)],
              ),
              const SizedBox(height: AppSpacing.sm),
              GradientText(
                'Match Over!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final (index, score) in sorted.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: PlayerTile(
                    rank: index + 1,
                    username: score.username,
                    trailing: '${score.score} pts',
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Play Again',
                  icon: Icons.replay_rounded,
                  gradient: AppGradients.electric,
                  foregroundColor: AppColors.textOnAccent,
                  onPressed: onPlayAgain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
