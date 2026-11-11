import 'bubble_clash_event.dart';
import 'initial_bubble.dart';

/// The full deterministic battle script sent by the server, for both
/// single-player and multiplayer Type Clash. The UI's job is to render
/// [initialBubbles] then play [events] back in order — never to compute
/// or decide anything itself.
class BubbleBattleResult {
  final List<InitialBubble> initialBubbles;
  final List<BubbleClashEvent> events;
  final String? winnerType;
  final String? winnerOwnerUsername;

  const BubbleBattleResult({
    required this.initialBubbles,
    required this.events,
    required this.winnerType,
    required this.winnerOwnerUsername,
  });

  factory BubbleBattleResult.fromJson(Map<String, dynamic> json) {
    return BubbleBattleResult(
      initialBubbles: (json['initialBubbles'] as List)
          .map((e) => InitialBubble.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List)
          .map((e) => BubbleClashEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      winnerType: json['winnerType'] as String?,
      winnerOwnerUsername: json['winnerOwnerUsername'] as String?,
    );
  }
}
