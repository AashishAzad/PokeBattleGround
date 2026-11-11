import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/round_start.dart';

/// Renders the round's Pokémon sprite behind a blur filter whose intensity
/// decreases over the round's duration — heavily blurred at the start,
/// perfectly clear right as time runs out. The countdown runs entirely
/// client-side from [round.durationSeconds]; the server only sends the
/// round's start event once; it doesn't need to tick every second.
///
/// IMPORTANT: callers must give this widget a fresh ValueKey(pokemonId)
/// each round (see who_is_that_pokemon_screen.dart) — otherwise Flutter
/// would reuse this State across rounds and the blur wouldn't reset.
class BlurredPokemonReveal extends StatefulWidget {
  final RoundStart round;

  const BlurredPokemonReveal({super.key, required this.round});

  @override
  State<BlurredPokemonReveal> createState() => _BlurredPokemonRevealState();
}

class _BlurredPokemonRevealState extends State<BlurredPokemonReveal> {
  static const _tickInterval = Duration(milliseconds: 100);
  static const _maxBlurSigma = 20.0;

  Timer? _timer;
  double _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_tickInterval, (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds += _tickInterval.inMilliseconds / 1000;
      });
      if (_elapsedSeconds >= widget.round.durationSeconds) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_elapsedSeconds / widget.round.durationSeconds).clamp(
      0.0,
      1.0,
    );
    final sigma = _maxBlurSigma * (1 - progress);
    final remaining = (widget.round.durationSeconds - _elapsedSeconds).clamp(
      0,
      widget.round.durationSeconds,
    );

    final timeLeft = 1 - progress;
    final urgent = timeLeft <= 0.25;

    return GlassContainer(
      constraints: const BoxConstraints(maxWidth: 360),
      borderRadius: AppRadii.xlAll,
      padding: const EdgeInsets.all(AppSpacing.lg - 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _Pill(
                icon: Icons.flag_rounded,
                label:
                    'Round ${widget.round.roundNumber} / ${widget.round.totalRounds}',
                color: AppColors.skyCyan,
              ),
              const Spacer(),
              _Pill(
                icon: Icons.timer_rounded,
                label: '${remaining.ceil()}s left',
                color: urgent ? AppColors.pokeRed : AppColors.electricYellow,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Scales the stage down on very narrow phones instead of overflowing.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox.square(
              dimension: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.skyCyan.withValues(alpha: 0.35),
                          AppColors.skyCyan.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: AppRadii.lgAll,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: sigma,
                        sigmaY: sigma,
                      ),
                      child: PokemonArtworkImage(
                        url: widget.round.spriteUrl,
                        size: 220,
                        shadow: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GradientProgressBar(
            value: timeLeft,
            duration: const Duration(milliseconds: 120),
            gradient: urgent ? AppGradients.danger : AppGradients.ocean,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.medium,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
