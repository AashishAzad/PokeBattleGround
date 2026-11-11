import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../models/game_mode.dart';

/// An illustrated, tappable card for one [GameMode].
///
/// [vertical] switches between a tall poster layout (multi-column, wide
/// screens) and a horizontal banner layout (single column, phones).
class GameModeCard extends StatelessWidget {
  final GameMode mode;
  final VoidCallback onTap;
  final bool vertical;

  const GameModeCard({
    super.key,
    required this.mode,
    required this.onTap,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = vertical ? 360.0 : 176.0;
    final artSize = vertical ? 190.0 : 150.0;
    final glow = mode.gradient.colors.first;

    return PressableScale(
      onTap: onTap,
      borderRadius: AppRadii.xlAll,
      semanticLabel: '${mode.title}. ${mode.tagline}',
      child: GlassContainer(
        height: height,
        blur: 12,
        padding: EdgeInsets.zero,
        borderRadius: AppRadii.xlAll,
        borderColor: Colors.white.withValues(alpha: 0.35),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            for (final c in mode.gradient.colors) c.withValues(alpha: 0.78),
          ],
        ),
        shadows: [
          BoxShadow(
            color: glow.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 14),
            spreadRadius: -10,
          ),
        ],
        child: Stack(
          children: [
            // Scrim keeps the white copy readable on bright gradients.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0x59000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -40,
              bottom: -40,
              child: PokeBall(
                size: height * 0.85,
                style: PokeBallStyle.outline,
                outlineColor: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            if (vertical)
              Positioned(
                top: AppSpacing.md,
                left: 0,
                right: 0,
                child: Center(
                  child: _Artwork(mode: mode, size: artSize),
                ),
              )
            else
              Positioned(
                right: -6,
                bottom: -6,
                child: _Artwork(mode: mode, size: artSize),
              ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg - 4,
                  AppSpacing.md + 2,
                  vertical ? AppSpacing.lg - 4 : artSize * 0.8,
                  AppSpacing.md + 2,
                ),
                child: _CardCopy(mode: mode, vertical: vertical),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final GameMode mode;
  final double size;

  const _Artwork({required this.mode, required this.size});

  @override
  Widget build(BuildContext context) {
    return FloatingAnimation(
      amplitude: 5,
      period: const Duration(milliseconds: 3400),
      child: PokemonArtworkImage(
        url: mode.artworkUrl,
        size: size,
        silhouette: mode.silhouette,
      ),
    );
  }
}

class _CardCopy extends StatelessWidget {
  final GameMode mode;
  final bool vertical;

  const _CardCopy({required this.mode, required this.vertical});

  static const _shadow = [Shadow(color: Colors.black45, blurRadius: 8)];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Icon(mode.icon, color: Colors.white, size: 22),
        ),
        const Spacer(),
        Text(
          mode.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.1,
            shadows: _shadow,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          mode.tagline,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            height: 1.3,
            shadows: _shadow,
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final tag in mode.tags) _Tag(tag)],
              ),
            ),
            if (vertical) ...[
              const SizedBox(width: AppSpacing.sm),
              const _PlayPill(),
            ],
          ],
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlayPill extends StatelessWidget {
  const _PlayPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.pillAll,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PLAY',
            style: TextStyle(
              color: AppColors.textOnAccent,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.play_arrow_rounded,
            color: AppColors.textOnAccent,
            size: 18,
          ),
        ],
      ),
    );
  }
}
