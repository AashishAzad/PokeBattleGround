class PlayerScore {
  final String userId;
  final String username;
  final int score;

  const PlayerScore({
    required this.userId,
    required this.username,
    required this.score,
  });

  factory PlayerScore.fromJson(Map<String, dynamic> json) {
    return PlayerScore(
      userId: json['userId'] as String,
      username: json['username'] as String,
      score: json['score'] as int,
    );
  }
}

class MatchEnd {
  final List<PlayerScore> finalScores;

  const MatchEnd({required this.finalScores});

  factory MatchEnd.fromJson(Map<String, dynamic> json) {
    return MatchEnd(
      finalScores: (json['finalScores'] as List)
          .map((e) => PlayerScore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
