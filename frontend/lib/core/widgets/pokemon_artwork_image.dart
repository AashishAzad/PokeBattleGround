import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import 'poke_ball.dart';

/// Network Pokémon artwork with a soft fade-in, a Poké Ball placeholder
/// while loading or on failure, and an optional drop shadow so the art
/// "pops" off glass surfaces.
///
/// [silhouette] renders it as a solid shape — the classic
/// "Who's that Pokémon?" look.
class PokemonArtworkImage extends StatelessWidget {
  final String url;
  final double size;
  final bool silhouette;
  final Color silhouetteColor;
  final bool shadow;
  final String? semanticLabel;

  const PokemonArtworkImage({
    super.key,
    required this.url,
    required this.size,
    this.silhouette = false,
    this.silhouetteColor = const Color(0xFF0D0B26),
    this.shadow = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: AppDurations.slow,
          child: frame == null
              ? _Placeholder(size: size, key: const ValueKey('placeholder'))
              : child,
        );
      },
      errorBuilder: (context, error, stackTrace) => _Placeholder(size: size),
    );

    if (silhouette) {
      image = ColorFiltered(
        colorFilter: ColorFilter.mode(silhouetteColor, BlendMode.srcIn),
        child: image,
      );
    }

    if (!shadow) return image;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: size * 0.2,
            spreadRadius: -size * 0.2,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: image,
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double size;

  const _Placeholder({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: PokeBall(
          size: size * 0.4,
          style: PokeBallStyle.outline,
          outlineColor: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
