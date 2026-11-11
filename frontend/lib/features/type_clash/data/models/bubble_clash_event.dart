/// One scripted collision between two specific bubbles, identified by id.
/// The UI looks these ids up among its rendered bubbles to know which two
/// to flash/resolve — it never needs spatial collision detection itself.
class BubbleClashEvent {
  final int round;
  final String bubbleAId;
  final String bubbleBId;
  final bool sameType;
  final int damageToA;
  final int damageToB;
  final int aRemainingPower;
  final int bRemainingPower;
  final List<String> eliminatedBubbleIds;

  const BubbleClashEvent({
    required this.round,
    required this.bubbleAId,
    required this.bubbleBId,
    required this.sameType,
    required this.damageToA,
    required this.damageToB,
    required this.aRemainingPower,
    required this.bRemainingPower,
    required this.eliminatedBubbleIds,
  });

  factory BubbleClashEvent.fromJson(Map<String, dynamic> json) {
    return BubbleClashEvent(
      round: json['round'] as int,
      bubbleAId: json['bubbleAId'] as String,
      bubbleBId: json['bubbleBId'] as String,
      sameType: json['sameType'] as bool,
      damageToA: json['damageToA'] as int,
      damageToB: json['damageToB'] as int,
      aRemainingPower: json['aRemainingPower'] as int,
      bRemainingPower: json['bRemainingPower'] as int,
      eliminatedBubbleIds: (json['eliminatedBubbleIds'] as List)
          .map((e) => e as String)
          .toList(),
    );
  }
}
