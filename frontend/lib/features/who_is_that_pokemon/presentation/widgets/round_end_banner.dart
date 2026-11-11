import 'package:flutter/material.dart';

class RoundEndBanner extends StatelessWidget {
  final String? pokemonName;

  const RoundEndBanner({super.key, required this.pokemonName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 40),
        const SizedBox(height: 8),
        Text(
          'It was ${pokemonName != null ? _capitalize(pokemonName!) : "..."}!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Next round starting soon...'),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
