import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../data/models/correct_guess.dart';

class CorrectGuessFeed extends StatelessWidget {
  final List<CorrectGuess> guesses;

  const CorrectGuessFeed({super.key, required this.guesses});

  @override
  Widget build(BuildContext context) {
    if (guesses.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: guesses.reversed.take(4).map((g) {
        return TweenAnimationBuilder<double>(
          key: ValueKey('${g.username}-${g.roundScore}'),
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.18),
              borderRadius: AppRadii.pillAll,
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  '${g.username} guessed right! +${g.roundScore}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
