class LeaderboardEntry {
  final String id;
  final String userId;
  final String username;
  final String gameType;
  final String mode;
  final int score;
  final DateTime createdAt;

  const LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.username,
    required this.gameType,
    required this.mode,
    required this.score,
    required this.createdAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      gameType: json['gameType'] as String,
      mode: json['mode'] as String,
      score: json['score'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
