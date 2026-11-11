import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Presentation metadata for the stat a Higher or Lower round compares,
/// keyed by the backend's `statKey`. Keeps labels, icons and colors in one
/// place instead of switch statements scattered through widgets.
enum PokemonStat {
  hp('hp', 'HP', Icons.favorite_rounded, AppColors.leafGreen),
  attack('attack', 'Attack', Icons.flash_on_rounded, AppColors.pokeRed),
  defense('defense', 'Defense', Icons.shield_rounded, AppColors.aquaBlue),
  specialAttack(
    'specialAttack',
    'Sp. Attack',
    Icons.auto_awesome_rounded,
    AppColors.sunsetOrange,
  ),
  specialDefense(
    'specialDefense',
    'Sp. Defense',
    Icons.security_rounded,
    AppColors.mysticPurple,
  ),
  speed('speed', 'Speed', Icons.speed_rounded, AppColors.skyCyan),
  unknown('', 'Stat', Icons.bar_chart_rounded, AppColors.electricYellow);

  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const PokemonStat(this.key, this.label, this.icon, this.color);

  /// Highest possible base stat in the main series (Blissey's HP).
  static const int maxBaseValue = 255;

  static PokemonStat fromKey(String? key) => PokemonStat.values.firstWhere(
    (stat) => stat.key == key,
    orElse: () => PokemonStat.unknown,
  );
}
