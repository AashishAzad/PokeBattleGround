import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../data/models/bubble_battle_result.dart';
import '../../data/models/bubble_clash_event.dart';
import 'type_colors.dart';

/// Renders the Type Clash battle as bubbles that float freely around the
/// arena between clashes — this idle drifting motion is purely local
/// decoration and is NOT synced between devices, by design: true
/// physics-perfect sync across devices isn't realistic to guarantee
/// fairly. What IS synced, identically for every viewer, is the actual
/// sequence of outcomes: for each scripted clash, the two involved bubbles
/// visibly travel toward each other until they meet, THEN the damage/pop
/// resolves — giving a real "collision" feel rather than a flash while
/// scattered far apart.
class BubbleArenaView extends StatefulWidget {
  final BubbleBattleResult result;
  final VoidCallback onPlayAgain;

  const BubbleArenaView({
    super.key,
    required this.result,
    required this.onPlayAgain,
  });

  @override
  State<BubbleArenaView> createState() => _BubbleArenaViewState();
}

class _Bubble {
  final String id;
  final String type;
  double power;
  Offset position;
  Offset velocity;
  bool alive;
  bool flashing;
  bool seeking; // currently animating toward a collision partner
  bool popping; // currently playing its elimination shrink/fade
  String? floatingText;

  _Bubble({
    required this.id,
    required this.type,
    required this.power,
    required this.position,
    required this.velocity,
  }) : alive = true,
       flashing = false,
       seeking = false,
       popping = false;
}

class _BubbleArenaViewState extends State<BubbleArenaView>
    with TickerProviderStateMixin {
  // All bubbles render at this fixed size — power is communicated only
  // through the number shown inside, never through size, so the arena
  // reads cleanly instead of some bubbles looking arbitrarily "weaker".
  static const double _bubbleRadius = 32;
  static const _flashDuration = Duration(milliseconds: 300);
  static const _seekDuration = Duration(milliseconds: 400);
  static const _popDuration = Duration(milliseconds: 250);

  final _random = Random();
  final List<_Bubble> _bubbles = [];

  Ticker? _ambientTicker;
  Duration _lastTick = Duration.zero;
  Size _arenaSize = const Size(320, 400);
  bool _battleFinished = false;

  @override
  void initState() {
    super.initState();
    for (final bubble in widget.result.initialBubbles) {
      _bubbles.add(
        _Bubble(
          id: bubble.id,
          type: bubble.type,
          power: bubble.power.toDouble(),
          position: Offset(
            _random.nextDouble() * _arenaSize.width,
            _random.nextDouble() * _arenaSize.height,
          ),
          velocity: _randomVelocity(),
        ),
      );
    }

    _ambientTicker = createTicker(_onAmbientTick)..start();

    if (widget.result.events.isEmpty) {
      _battleFinished = true;
    } else {
      _startEventPlayback();
    }
  }

  @override
  void dispose() {
    _ambientTicker?.dispose();
    super.dispose();
  }

  Offset _randomVelocity() {
    return Offset((_random.nextDouble() - 0.5) * 40, (_random.nextDouble() - 0.5) * 40);
  }

  // Continuous idle-floating physics — runs every frame, but skips any
  // bubble currently mid-collision (seeking) or mid-elimination (popping),
  // since those states drive their own position/opacity explicitly.
  void _onAmbientTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0 || dt > 0.25) return; // guard against a huge first-frame dt

    for (final bubble in _bubbles) {
      if (!bubble.alive || bubble.seeking || bubble.popping) continue;

      var newPos = bubble.position + bubble.velocity * dt;
      var vx = bubble.velocity.dx;
      var vy = bubble.velocity.dy;
      const r = _bubbleRadius;

      if (newPos.dx < r || newPos.dx > _arenaSize.width - r) {
        vx = -vx;
        newPos = Offset(newPos.dx.clamp(r, _arenaSize.width - r), newPos.dy);
      }
      if (newPos.dy < r || newPos.dy > _arenaSize.height - r) {
        vy = -vy;
        newPos = Offset(newPos.dx, newPos.dy.clamp(r, _arenaSize.height - r));
      }

      bubble.position = newPos;
      bubble.velocity = Offset(vx, vy);
    }

    if (mounted) setState(() {});
  }

  Future<void> _startEventPlayback() async {
    for (final event in widget.result.events) {
      if (!mounted) return;
      await _playEvent(event);
    }
    if (mounted) setState(() => _battleFinished = true);
  }

  Future<void> _playEvent(BubbleClashEvent event) async {
    final bubbleA = _findBubble(event.bubbleAId);
    final bubbleB = _findBubble(event.bubbleBId);
    if (bubbleA == null || bubbleB == null) return;
    if (!bubbleA.alive || !bubbleB.alive) return; // defensive guard

    // Compute two rendezvous points along the line between the bubbles'
    // CURRENT positions, offset so their edges end up touching exactly at
    // the midpoint — a real "meeting", not a full overlap.
    final direction = bubbleB.position - bubbleA.position;
    final dist = direction.distance;
    final unit = dist == 0 ? const Offset(1, 0) : direction / dist;
    final mid = Offset.lerp(bubbleA.position, bubbleB.position, 0.5)!;
    final targetA = mid - unit * _bubbleRadius;
    final targetB = mid + unit * _bubbleRadius;

    setState(() {
      bubbleA.seeking = true;
      bubbleB.seeking = true;
    });

    await _animateSeek(
      a: bubbleA,
      targetA: targetA,
      b: bubbleB,
      targetB: targetB,
    );
    if (!mounted) return;

    // The two bubbles have now visibly met — resolve the clash.
    setState(() {
      bubbleA.flashing = true;
      bubbleB.flashing = true;
      bubbleA.power = event.aRemainingPower.toDouble();
      bubbleB.power = event.bRemainingPower.toDouble();
      bubbleA.floatingText = event.damageToA > 0 ? '-${event.damageToA}' : null;
      bubbleB.floatingText = event.damageToB > 0 ? '-${event.damageToB}' : null;
    });

    await Future.delayed(_flashDuration);
    if (!mounted) return;

    final aEliminated = event.eliminatedBubbleIds.contains(bubbleA.id);
    final bEliminated = event.eliminatedBubbleIds.contains(bubbleB.id);

    setState(() {
      bubbleA.flashing = false;
      bubbleB.flashing = false;
      bubbleA.floatingText = null;
      bubbleB.floatingText = null;
      bubbleA.seeking = false;
      bubbleB.seeking = false;
      if (aEliminated) {
        bubbleA.popping = true;
      } else {
        bubbleA.velocity = _randomVelocity(); // bounce apart if it survived
      }
      if (bEliminated) {
        bubbleB.popping = true;
      } else {
        bubbleB.velocity = _randomVelocity();
      }
    });

    if (aEliminated || bEliminated) {
      await Future.delayed(_popDuration);
      if (!mounted) return;
      setState(() {
        if (aEliminated) bubbleA.alive = false;
        if (bEliminated) bubbleB.alive = false;
      });
    }

    // Brief pause before the next scripted clash, so consecutive events
    // don't feel instantaneous back-to-back.
    await Future.delayed(const Duration(milliseconds: 150));
  }

  // Smoothly interpolates both bubbles from their current position to
  // their target over a fixed duration using a short-lived
  // AnimationController — this guarantees they arrive at exactly the same
  // moment regardless of how far apart they started.
  Future<void> _animateSeek({
    required _Bubble a,
    required Offset targetA,
    required _Bubble b,
    required Offset targetB,
  }) async {
    final startA = a.position;
    final startB = b.position;
    final controller = AnimationController(vsync: this, duration: _seekDuration);
    controller.addListener(() {
      if (!mounted) return;
      setState(() {
        a.position = Offset.lerp(startA, targetA, controller.value)!;
        b.position = Offset.lerp(startB, targetB, controller.value)!;
      });
    });
    await controller.forward();
    controller.dispose();
  }

  _Bubble? _findBubble(String id) {
    for (final b in _bubbles) {
      if (b.id == id) return b;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Battle!', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 400.0;
            _arenaSize = Size(width, height);

            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  for (final bubble in _bubbles.where((b) => b.alive))
                    _buildBubble(bubble),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        if (_battleFinished) _buildWinnerBanner(context),
      ],
    );
  }

  Widget _buildBubble(_Bubble bubble) {
    final color = colorForType(bubble.type);
    final icon = iconForType(bubble.type);
    const r = _bubbleRadius;

    return Positioned(
      left: bubble.position.dx - r,
      top: bubble.position.dy - r,
      child: AnimatedScale(
        scale: bubble.popping ? 0 : 1,
        duration: _popDuration,
        curve: Curves.easeIn,
        child: AnimatedOpacity(
          opacity: bubble.popping ? 0 : 1,
          duration: _popDuration,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey('${bubble.id}-${bubble.flashing}'),
                tween: Tween(begin: bubble.flashing ? 1.25 : 1.0, end: 1.0),
                duration: const Duration(milliseconds: 250),
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Container(
                  width: r * 2,
                  height: r * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.25),
                    border: Border.all(
                      color: bubble.flashing ? Colors.white : color,
                      width: bubble.flashing ? 3 : 2,
                    ),
                    boxShadow: bubble.flashing
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 18),
                      Text(
                        bubble.power.round().toString(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (bubble.floatingText != null)
                Positioned(
                  top: -18,
                  child: Text(
                    bubble.floatingText!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerBanner(BuildContext context) {
    final winnerType = widget.result.winnerType;
    return Column(
      children: [
        if (winnerType != null) ...[
          Icon(Icons.emoji_events, color: colorForType(winnerType), size: 48),
          const SizedBox(height: 8),
          Text(
            '${_capitalize(winnerType)} wins!',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (widget.result.winnerOwnerUsername != null)
            Text('Claimed by ${widget.result.winnerOwnerUsername}'),
        ] else
          const Text('No winner — draw!'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: widget.onPlayAgain,
          child: const Text('Play Again'),
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
