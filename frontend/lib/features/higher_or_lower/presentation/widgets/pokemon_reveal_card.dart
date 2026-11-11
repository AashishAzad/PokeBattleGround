import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/higher_or_lower_pokemon.dart';
import '../models/pokemon_stat.dart';

/// Displays a single Pokémon's artwork, name, and the stat value being
/// compared on a glass card, with a smooth fade+scale transition whenever
/// the underlying Pokémon changes (keyed by pokemon.id, so AnimatedSwitcher
/// knows a genuinely new Pokémon has replaced the old one).
///
/// The artwork sits beside the stats when there's room, and stacks above
/// them on very narrow screens.
class PokemonRevealCard extends StatelessWidget {
  final HigherOrLowerPokemon pokemon;
  final PokemonStat stat;
  final bool highlightWrong;

  const PokemonRevealCard({
    super.key,
    required this.pokemon,
    required this.stat,
    this.highlightWrong = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = highlightWrong ? AppColors.danger : stat.color;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: GlassContainer(
        key: ValueKey(pokemon.id),
        borderRadius: AppRadii.xlAll,
        padding: const EdgeInsets.all(AppSpacing.lg - 4),
        borderColor: accent.withValues(alpha: highlightWrong ? 0.9 : 0.5),
        borderWidth: highlightWrong ? 2.4 : 1.4,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.22), AppColors.glassFillSubtle],
        ),
        shadows: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 36,
            offset: const Offset(0, 16),
            spreadRadius: -12,
          ),
        ],
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide = constraints.maxWidth >= 340;
            final artSize = sideBySide
                ? (constraints.maxWidth * 0.42).clamp(130.0, 220.0)
                : 170.0;
            final artwork = _ArtworkStage(
              pokemon: pokemon,
              accent: accent,
              size: artSize,
            );
            final info = _StatPanel(
              pokemon: pokemon,
              stat: stat,
              accent: accent,
              centered: !sideBySide,
            );

            if (sideBySide) {
              return Row(
                children: [
                  artwork,
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: info),
                ],
              );
            }
            return Column(
              children: [
                artwork,
                const SizedBox(height: AppSpacing.md),
                info,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArtworkStage extends StatelessWidget {
  final HigherOrLowerPokemon pokemon;
  final Color accent;
  final double size;

  const _ArtworkStage({
    required this.pokemon,
    required this.accent,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.45),
                  accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          PokeBall(
            size: size * 0.9,
            style: PokeBallStyle.outline,
            outlineColor: Colors.white.withValues(alpha: 0.12),
          ),
          FloatingAnimation(
            amplitude: 5,
            child: PokemonArtworkImage(
              url: pokemon.spriteUrl,
              size: size * 0.92,
              semanticLabel: pokemon.name.capitalized,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPanel extends StatelessWidget {
  final HigherOrLowerPokemon pokemon;
  final PokemonStat stat;
  final Color accent;
  final bool centered;

  const _StatPanel({
    required this.pokemon,
    required this.stat,
    required this.accent,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final align = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '#${pokemon.id.toString().padLeft(4, '0')}',
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          pokemon.name.capitalized,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: textTheme.headlineSmall?.copyWith(height: 1.1),
        ),
        const SizedBox(height: AppSpacing.md),
        _StatChip(stat: stat, color: accent),
        const SizedBox(height: AppSpacing.sm),
        // Count up to the value each time a new Pokémon is revealed.
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: pokemon.statValue),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Text(
            '$value',
            semanticsLabel: '${stat.label} ${pokemon.statValue}',
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              shadows: [
                Shadow(color: accent.withValues(alpha: 0.8), blurRadius: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GradientProgressBar(
          value: pokemon.statValue / PokemonStat.maxBaseValue,
          duration: const Duration(milliseconds: 700),
          gradient: LinearGradient(
            colors: [accent.withValues(alpha: 0.7), accent],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final PokemonStat stat;
  final Color color;

  const _StatChip({required this.stat, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stat.icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            stat.label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
