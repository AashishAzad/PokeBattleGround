class LobbyPlayer {
  final String socketId;
  final String userId;
  final String username;

  const LobbyPlayer({
    required this.socketId,
    required this.userId,
    required this.username,
  });

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      socketId: json['socketId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
    );
  }
}
