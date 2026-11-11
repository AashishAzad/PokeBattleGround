/// The Pokémon data shown during a Higher or Lower round. Deliberately
/// narrower than a full Pokémon profile — this only contains what the
/// backend actually sends for this game (id, name, sprite, and the one
/// stat value being compared).
class HigherOrLowerPokemon {
  final int id;
  final String name;
  final String spriteUrl;
  final int statValue;

  const HigherOrLowerPokemon({
    required this.id,
    required this.name,
    required this.spriteUrl,
    required this.statValue,
  });

  factory HigherOrLowerPokemon.fromJson(Map<String, dynamic> json) {
    return HigherOrLowerPokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      spriteUrl: json['spriteUrl'] as String,
      statValue: json['statValue'] as int,
    );
  }
}
