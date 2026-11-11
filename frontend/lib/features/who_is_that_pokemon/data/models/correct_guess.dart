class CorrectGuess {
  final String username;
  final int roundScore;

  const CorrectGuess({required this.username, required this.roundScore});

  factory CorrectGuess.fromJson(Map<String, dynamic> json) {
    return CorrectGuess(
      username: json['username'] as String,
      roundScore: json['roundScore'] as int,
    );
  }
}
