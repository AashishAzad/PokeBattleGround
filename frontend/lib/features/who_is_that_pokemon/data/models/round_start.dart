/// The server deliberately never sends the Pokémon's name here — only
/// enough to render the sprite and run the local reveal countdown. The
/// blur/clarity effect is the only clue the player gets.
class RoundStart {
  final int pokemonId;
  final String spriteUrl;
  final int durationSeconds;
  final int roundNumber;
  final int totalRounds;

  const RoundStart({
    required this.pokemonId,
    required this.spriteUrl,
    required this.durationSeconds,
    required this.roundNumber,
    required this.totalRounds,
  });

  factory RoundStart.fromJson(Map<String, dynamic> json) {
    return RoundStart(
      pokemonId: json['pokemonId'] as int,
      spriteUrl: json['spriteUrl'] as String,
      durationSeconds: json['durationSeconds'] as int,
      roundNumber: json['roundNumber'] as int,
      totalRounds: json['totalRounds'] as int,
    );
  }
}
