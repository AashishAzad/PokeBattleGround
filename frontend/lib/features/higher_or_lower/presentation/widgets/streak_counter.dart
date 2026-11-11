import 'package:flutter/material.dart';

/// Shows the current streak with a subtle pop animation whenever it
/// changes (keyed by streak value), giving the player satisfying feedback
/// per round without needing an AnimationController to manage manually.
class StreakCounter extends StatelessWidget {
  final int streak;

  const StreakCounter({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(streak),
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Chip(
        avatar: const Icon(Icons.local_fire_department, color: Colors.orange),
        label: Text(
          'Streak: $streak',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
