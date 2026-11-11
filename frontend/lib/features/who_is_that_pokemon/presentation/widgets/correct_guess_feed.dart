import 'package:flutter/material.dart';

import '../../data/models/correct_guess.dart';

class CorrectGuessFeed extends StatelessWidget {
  final List<CorrectGuess> guesses;

  const CorrectGuessFeed({super.key, required this.guesses});

  @override
  Widget build(BuildContext context) {
    if (guesses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: guesses.reversed.take(4).map((g) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '${g.username} guessed right! +${g.roundScore}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}
