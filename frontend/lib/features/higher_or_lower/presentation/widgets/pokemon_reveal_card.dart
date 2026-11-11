import 'package:flutter/material.dart';

import '../../data/models/higher_or_lower_pokemon.dart';

/// Displays a single Pokémon's sprite, name, and the stat value being
/// compared, with a smooth fade+scale transition whenever the underlying
/// Pokémon changes (keyed by pokemon.id, so AnimatedSwitcher knows a
/// genuinely new Pokémon has replaced the old one).
class PokemonRevealCard extends StatelessWidget {
  final HigherOrLowerPokemon pokemon;
  final String statLabel;
  final bool highlightWrong;

  const PokemonRevealCard({
    super.key,
    required this.pokemon,
    required this.statLabel,
    this.highlightWrong = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = highlightWrong
        ? Colors.redAccent
        : Theme.of(context).colorScheme.outlineVariant;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: Container(
        key: ValueKey(pokemon.id),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              pokemon.spriteUrl,
              height: 140,
              width: 140,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.help_outline, size: 140),
            ),
            const SizedBox(height: 8),
            Text(
              _capitalize(pokemon.name),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '$statLabel: ${pokemon.statValue}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
