import 'package:flutter/material.dart';

import '../../../../core/constants/pokemon_artwork.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../higher_or_lower/presentation/screens/higher_or_lower_screen.dart';
import '../../../type_clash/presentation/screens/type_clash_screen.dart';
import '../../../who_is_that_pokemon/presentation/screens/who_is_that_pokemon_screen.dart';

/// Describes one playable game for the Home screen. The Home UI is built
/// purely from this data, so adding a new game means adding one entry to
/// [gameModes] — no card or layout code changes (open/closed).
class GameMode {
  final String title;
  final String tagline;
  final List<String> tags;
  final IconData icon;
  final LinearGradient gradient;
  final int artworkDexId;

  /// Render the mascot as a black silhouette (fits "Who Is That Pokémon?").
  final bool silhouette;
  final WidgetBuilder screenBuilder;

  const GameMode({
    required this.title,
    required this.tagline,
    required this.tags,
    required this.icon,
    required this.gradient,
    required this.artworkDexId,
    required this.screenBuilder,
    this.silhouette = false,
  });

  String get artworkUrl => PokemonArtwork.officialArtwork(artworkDexId);
}

final List<GameMode> gameModes = [
  GameMode(
    title: 'Higher or Lower',
    tagline: 'Guess whose stat is bigger and build your streak.',
    tags: const ['Solo', 'Streak'],
    icon: Icons.swap_vert_rounded,
    gradient: AppGradients.electric,
    artworkDexId: PokemonArtwork.pikachu,
    screenBuilder: (_) => const HigherOrLowerScreen(),
  ),
  GameMode(
    title: 'Type Clash',
    tagline: 'Pick a type and watch the bubbles battle it out.',
    tags: const ['Solo', 'Multiplayer'],
    icon: Icons.bubble_chart_rounded,
    gradient: AppGradients.blaze,
    artworkDexId: PokemonArtwork.charizard,
    screenBuilder: (_) => const TypeClashScreen(),
  ),
  GameMode(
    title: 'Who Is That Pokémon?',
    tagline: 'Name the Pokémon before the blur clears.',
    tags: const ['2-4 players', 'Live'],
    icon: Icons.visibility_rounded,
    gradient: AppGradients.mystic,
    artworkDexId: PokemonArtwork.mewtwo,
    silhouette: true,
    screenBuilder: (_) => const WhoIsThatPokemonScreen(),
  ),
];
