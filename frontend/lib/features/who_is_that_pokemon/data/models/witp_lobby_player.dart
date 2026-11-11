class WitpLobbyPlayer {
  final String socketId;
  final String userId;
  final String username;

  const WitpLobbyPlayer({
    required this.socketId,
    required this.userId,
    required this.username,
  });

  factory WitpLobbyPlayer.fromJson(Map<String, dynamic> json) {
    return WitpLobbyPlayer(
      socketId: json['socketId'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
    );
  }
}
