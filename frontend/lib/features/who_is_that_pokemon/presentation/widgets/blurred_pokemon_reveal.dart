import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Round ${widget.round.roundNumber} / ${widget.round.totalRounds}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: Image.network(
              widget.round.spriteUrl,
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 220,
                height: 220,
                child: Icon(Icons.help_outline, size: 100),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 4),
        Text('${remaining.ceil()}s left'),
      ],
    );
  }
}
