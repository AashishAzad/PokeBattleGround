/// Note: weightedScore comes back from Postgres as a STRING (SUM() returns
/// a numeric type, and the driver stringifies it to avoid silent precision
/// loss on very large sums) — this model parses it into a real number so
/// the UI can sort/format it normally without that quirk leaking through.
class GlobalRankingEntry {
  final String userId;
  final String username;
  final double weightedScore;

  const GlobalRankingEntry({
    required this.userId,
    required this.username,
    required this.weightedScore,
  });

  factory GlobalRankingEntry.fromJson(Map<String, dynamic> json) {
    return GlobalRankingEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      weightedScore: double.parse(json['weightedScore'].toString()),
    );
  }
}
