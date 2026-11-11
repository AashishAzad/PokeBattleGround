class RoundEnd {
  final String? pokemonName;
  final int roundNumber;

  const RoundEnd({required this.pokemonName, required this.roundNumber});

  factory RoundEnd.fromJson(Map<String, dynamic> json) {
    return RoundEnd(
      pokemonName: json['pokemonName'] as String?,
      roundNumber: json['roundNumber'] as int,
    );
  }
}
