/// One bubble's starting state when a battle begins. Each claimed type
/// spawns several of these (see TypeClashBattleService on the backend).
class InitialBubble {
  final String id;
  final String type;
  final int power;
  final String? ownerUsername;

  const InitialBubble({
    required this.id,
    required this.type,
    required this.power,
    required this.ownerUsername,
  });

  factory InitialBubble.fromJson(Map<String, dynamic> json) {
    return InitialBubble(
      id: json['id'] as String,
      type: json['type'] as String,
      power: json['power'] as int,
      ownerUsername: json['ownerUsername'] as String?,
    );
  }
}
