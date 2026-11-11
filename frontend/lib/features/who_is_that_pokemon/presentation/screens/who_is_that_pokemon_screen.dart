import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user/data/models/app_user.dart';
import '../../../user/presentation/providers/current_user_provider.dart';
import '../providers/who_is_that_pokemon_game_notifier.dart';
import '../providers/who_is_that_pokemon_game_state.dart';
import '../widgets/blurred_pokemon_reveal.dart';
import '../widgets/correct_guess_feed.dart';
import '../widgets/guess_input_bar.dart';
import '../widgets/match_end_view.dart';
import '../widgets/round_end_banner.dart';
import '../widgets/witp_lobby_waiting_view.dart';

class WhoIsThatPokemonScreen extends ConsumerWidget {
  const WhoIsThatPokemonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Who Is That Pokémon?')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load profile: $err')),
        data: (user) => _WitpBody(user: user),
      ),
    );
  }
}

class _WitpBody extends ConsumerWidget {
  final AppUser user;

  const _WitpBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(whoIsThatPokemonGameProvider(user));
    final notifier = ref.read(whoIsThatPokemonGameProvider(user).notifier);

    if (gameState.phase == WitpPhase.choosingToJoin) {
      // Kick off joining the lobby as soon as the screen opens.
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.joinLobby());
      return const Center(child: CircularProgressIndicator());
    }

    final Widget content;
    switch (gameState.phase) {
      case WitpPhase.choosingToJoin:
        content = const SizedBox.shrink(); // handled by the early return above
        break;
      case WitpPhase.inLobby:
        content = WitpLobbyWaitingView(players: gameState.lobbyPlayers);
        break;
      case WitpPhase.roundActive:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlurredPokemonReveal(
              // A fresh key per round forces the blur-countdown State to
              // reset instead of being reused across different Pokémon.
              key: ValueKey(gameState.currentRound!.pokemonId),
              round: gameState.currentRound!,
            ),
            const SizedBox(height: 16),
            if (gameState.hasGuessedCorrectly)
              Text(
                'Correct! +${gameState.myRoundScore} points',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            else
              GuessInputBar(enabled: true, onSubmit: notifier.submitGuess),
            const SizedBox(height: 16),
            CorrectGuessFeed(guesses: gameState.recentCorrectGuesses),
          ],
        );
        break;
      case WitpPhase.roundEnded:
        content = RoundEndBanner(
          pokemonName: gameState.lastRoundEnd?.pokemonName,
        );
        break;
      case WitpPhase.matchEnded:
        content = MatchEndView(
          finalScores: gameState.finalScores ?? [],
          onPlayAgain: notifier.playAgain,
        );
        break;
      case WitpPhase.error:
        content = Text('Error: ${gameState.errorMessage}');
        break;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (gameState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gameState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
            ],
            content,
          ],
        ),
      ),
    );
  }
}
