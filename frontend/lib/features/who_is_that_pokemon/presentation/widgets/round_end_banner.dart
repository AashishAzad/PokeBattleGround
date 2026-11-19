import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/widgets.dart';

class RoundEndBanner extends StatelessWidget {
  final String? pokemonName;

  const RoundEndBanner({super.key, required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return EntranceAnimation(
      child: GlassContainer(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderColor: AppColors.success.withValues(alpha: 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('It was', style: textTheme.titleMedium),
            GradientText(
              '${pokemonName?.capitalized ?? "..."}!',
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PokeBallLoader(size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Next round starting soon...',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
