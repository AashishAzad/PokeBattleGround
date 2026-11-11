import 'package:flutter/material.dart';

import '../../data/models/match_end.dart';

class MatchEndView extends StatelessWidget {
  final List<PlayerScore> finalScores;
  final VoidCallback onPlayAgain;

  const MatchEndView({
    super.key,
    required this.finalScores,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...finalScores]..sort((a, b) => b.score.compareTo(a.score));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
        const SizedBox(height: 8),
        Text('Match Over!', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...sorted.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final score = entry.value;
          return ListTile(
            leading: CircleAvatar(child: Text('$rank')),
            title: Text(score.username),
            trailing: Text(
              '${score.score} pts',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onPlayAgain, child: const Text('Play Again')),
      ],
    );
  }
}
