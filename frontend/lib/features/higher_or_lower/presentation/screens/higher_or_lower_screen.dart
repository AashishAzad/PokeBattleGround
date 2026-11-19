import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../user/presentation/providers/current_user_provider.dart';
import '../models/pokemon_stat.dart';
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

    return GlassScaffold(
      title: 'Higher or Lower',
      body: userAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(message: 'Failed to load profile: $err'),
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
    final stat = PokemonStat.fromKey(gameState.statKey);

    if (gameState.status == HigherOrLowerStatus.initial) {
      // Kick off the first round as soon as the screen opens.
      // addPostFrameCallback avoids calling startGame() mid-build, which
      // Riverpod disallows (state mutation during widget build).
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.startGame());
      return const LoadingView(message: 'Finding a wild Pokémon...');
    }

    if (gameState.status == HigherOrLowerStatus.error) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ErrorView(
          message: '${gameState.errorMessage}',
          onRetry: notifier.startGame,
        ),
      );
    }

    final Widget content;
    if (gameState.status == HigherOrLowerStatus.gameOver) {
      content = _GameOverView(
        state: gameState,
        stat: stat,
        onPlayAgain: notifier.startGame,
      );
    } else {
      content = _PlayingView(
        state: gameState,
        stat: stat,
        onGuess: notifier.submitGuess,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppBreakpoints.contentMaxWidth,
        ),
        child: content,
      ),
    );
  }
}

class _PlayingView extends StatelessWidget {
  final HigherOrLowerGameState state;
  final PokemonStat stat;
  final ValueChanged<String> onGuess;

  const _PlayingView({
    required this.state,
    required this.stat,
    required this.onGuess,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == HigherOrLowerStatus.loading;
    final pokemon = state.currentPokemon;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + 4,
        AppSpacing.sm,
        AppSpacing.md + 4,
        AppSpacing.md + 4,
      ),
      child: Column(
        children: [
          StreakCounter(streak: state.streak),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: pokemon != null
                    ? PokemonRevealCard(pokemon: pokemon, stat: stat)
                    : const LoadingView(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _QuestionPrompt(
            stat: stat,
            isLoading: isLoading,
            loadingLabel: pokemon == null
                ? 'Finding a wild Pokémon...'
                : 'Revealing the next Pokémon...',
          ),
          const SizedBox(height: AppSpacing.md),
          // Buttons stay in place (just disabled) while a guess resolves,
          // so the layout doesn't jump between rounds.
          GuessButtons(enabled: !isLoading, onGuess: onGuess),
        ],
      ),
    );
  }
}

class _QuestionPrompt extends StatelessWidget {
  final PokemonStat stat;
  final bool isLoading;
  final String loadingLabel;

  const _QuestionPrompt({
    required this.stat,
    required this.isLoading,
    required this.loadingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium;

    return SizedBox(
      height: 48,
      child: AnimatedSwitcher(
        duration: AppDurations.medium,
        child: isLoading
            ? Row(
                key: const ValueKey('loading'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PokeBallLoader(size: 26),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Text(loadingLabel, style: style),
                ],
              )
            : Text.rich(
                key: const ValueKey('question'),
                TextSpan(
                  children: [
                    const TextSpan(text: 'Will the next Pokémon have '),
                    TextSpan(
                      text: 'higher',
                      style: const TextStyle(
                        color: AppColors.leafGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: ' or '),
                    TextSpan(
                      text: 'lower',
                      style: const TextStyle(
                        color: AppColors.pokeRed,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: stat.label,
                      style: TextStyle(
                        color: stat.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: style,
              ),
      ),
    );
  }
}

class _GameOverView extends StatelessWidget {
  final HigherOrLowerGameState state;
  final PokemonStat stat;
  final VoidCallback onPlayAgain;

  const _GameOverView({
    required this.state,
    required this.stat,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: EntranceAnimation(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientText(
                'Game Over!',
                gradient: AppGradients.brandText,
                style: textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Final streak', style: textTheme.titleMedium),
              Text(
                '${state.streak}',
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.electricYellow,
                  shadows: const [
                    Shadow(color: AppColors.sunsetOrange, blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.currentPokemon != null) ...[
                Text('The next Pokémon was...', style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                PokemonRevealCard(
                  pokemon: state.currentPokemon!,
                  stat: stat,
                  highlightWrong: true,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: 'Play Again',
                  icon: Icons.replay_rounded,
                  gradient: AppGradients.electric,
                  foregroundColor: AppColors.textOnAccent,
                  onPressed: onPlayAgain,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Back to games'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
