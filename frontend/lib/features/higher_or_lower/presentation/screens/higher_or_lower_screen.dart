import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user/presentation/providers/current_user_provider.dart';
import '../providers/higher_or_lower_game_notifier.dart';
import '../providers/higher_or_lower_game_state.dart';
import '../widgets/guess_buttons.dart';
import '../widgets/pokemon_reveal_card.dart';
import '../widgets/streak_counter.dart';

class HigherOrLowerScreen extends ConsumerWidget {
  const HigherOrLowerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // currentUserProvider hands us the signed-in user; this screen just
    // reacts to its three possible states via AsyncValue.when.
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Higher or Lower')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load profile: $err')),
        data: (user) => _GameBody(userId: user.id),
      ),
    );
  }
}

class _GameBody extends ConsumerWidget {
  final String userId;

  const _GameBody({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(higherOrLowerGameProvider(userId));
    final notifier = ref.read(higherOrLowerGameProvider(userId).notifier);

    if (gameState.status == HigherOrLowerStatus.initial) {
      // Kick off the first round as soon as the screen opens.
      // addPostFrameCallback avoids calling startGame() mid-build, which
      // Riverpod disallows (state mutation during widget build).
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.startGame());
      return const Center(child: CircularProgressIndicator());
    }

    if (gameState.status == HigherOrLowerStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Something went wrong: ${gameState.errorMessage}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: notifier.startGame,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (gameState.status == HigherOrLowerStatus.gameOver) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Final streak: ${gameState.streak}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            if (gameState.currentPokemon != null)
              PokemonRevealCard(
                pokemon: gameState.currentPokemon!,
                statLabel: _statLabel(gameState.statKey),
                highlightWrong: true,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: notifier.startGame,
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }

    final isLoading = gameState.status == HigherOrLowerStatus.loading;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StreakCounter(streak: gameState.streak),
          const SizedBox(height: 24),
          if (gameState.currentPokemon != null)
            PokemonRevealCard(
              pokemon: gameState.currentPokemon!,
              statLabel: _statLabel(gameState.statKey),
            ),
          const Spacer(),
          Text(
            'Will the next Pokémon have higher or lower ${_statLabel(gameState.statKey)}?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const CircularProgressIndicator()
          else
            GuessButtons(enabled: !isLoading, onGuess: notifier.submitGuess),
        ],
      ),
    );
  }

  String _statLabel(String? key) {
    switch (key) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'specialAttack':
        return 'Sp. Attack';
      case 'specialDefense':
        return 'Sp. Defense';
      case 'speed':
        return 'Speed';
      default:
        return 'Stat';
    }
  }
}
