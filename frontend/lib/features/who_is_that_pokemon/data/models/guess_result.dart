class GuessResult {
  final bool correct;
  final bool alreadyGuessed;
  final int score;

  const GuessResult({
    required this.correct,
    required this.alreadyGuessed,
    required this.score,
  });

  factory GuessResult.fromJson(Map<String, dynamic> json) {
    return GuessResult(
      correct: json['correct'] as bool,
      alreadyGuessed: json['alreadyGuessed'] as bool,
      score: json['score'] as int,
    );
  }
}
