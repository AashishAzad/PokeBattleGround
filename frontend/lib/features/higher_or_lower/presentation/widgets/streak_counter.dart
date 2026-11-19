import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Shows the current streak with a subtle pop animation whenever it
/// changes (keyed by streak value), giving the player satisfying feedback
/// per round without needing an AnimationController to manage manually.
class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final onFire = streak >= 3;

    return TweenAnimationBuilder<double>(
      key: ValueKey(streak),
      tween: Tween(begin: 0.75, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 16, 6),
        decoration: BoxDecoration(
          borderRadius: AppRadii.pillAll,
          gradient: LinearGradient(
            colors: [
              AppColors.sunsetOrange.withValues(alpha: onFire ? 0.55 : 0.25),
              AppColors.pokeRed.withValues(alpha: onFire ? 0.45 : 0.15),
            ],
          ),
          border: Border.all(
            color: AppColors.sunsetOrange.withValues(alpha: 0.7),
          ),
          boxShadow: onFire
              ? [
                  BoxShadow(
                    color: AppColors.sunsetOrange.withValues(alpha: 0.5),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.electricYellow,
              size: 24,
            ),
            const SizedBox(width: 6),
            Text(
              'Streak',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$streak',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
