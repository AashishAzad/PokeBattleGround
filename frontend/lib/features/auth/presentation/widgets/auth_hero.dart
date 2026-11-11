import 'package:flutter/material.dart';

import '../../../../core/constants/pokemon_artwork.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// Illustrated header for the login screen: three floating mascots around
/// a glowing Poké Ball, the wordmark and a tagline. [scale] lets the same
/// composition serve both the compact (phone) and wide (desktop) layouts.
class AuthHero extends StatelessWidget {
  final double scale;

  const AuthHero({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    final stageHeight = 200 * scale;
    final stageWidth = 340 * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: stageWidth,
          height: stageHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Soft halo behind the mascots.
              Container(
                width: stageHeight * 0.95,
                height: stageHeight * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.electricYellow.withValues(alpha: 0.35),
                      AppColors.electricYellow.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: _Mascot(
                  dexId: PokemonArtwork.charizard,
                  size: 120 * scale,
                  period: const Duration(milliseconds: 3600),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 4 * scale,
                child: _Mascot(
                  dexId: PokemonArtwork.gengar,
                  size: 108 * scale,
                  period: const Duration(milliseconds: 4200),
                ),
              ),
              Positioned(
                top: 0,
                child: FloatingAnimation(
                  amplitude: 6,
                  rotation: 0.08,
                  period: const Duration(milliseconds: 2600),
                  child: PokeBall(size: 40 * scale),
                ),
              ),
              Positioned(
                bottom: 0,
                child: _Mascot(
                  dexId: PokemonArtwork.pikachu,
                  size: 150 * scale,
                  period: const Duration(milliseconds: 3000),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md * scale),
        BrandTitle(fontSize: 34 * scale),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Battle, guess & climb the leaderboard.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _Mascot extends StatelessWidget {
  final int dexId;
  final double size;
  final Duration period;

  const _Mascot({
    required this.dexId,
    required this.size,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingAnimation(
      period: period,
      amplitude: 6,
      child: PokemonArtworkImage(
        url: PokemonArtwork.officialArtwork(dexId),
        size: size,
      ),
    );
  }
}
