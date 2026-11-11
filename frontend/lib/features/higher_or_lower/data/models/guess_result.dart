import 'higher_or_lower_pokemon.dart';

/// Response shape from POST /higher-or-lower/guess.
///
/// The backend returns `streak` when the guess is correct, but
/// `finalStreak` when it's wrong (two names for what is conceptually the
/// same value: "the streak count after this guess"). We normalize both
/// into `resultingStreak` right here, so the UI layer never needs to know
/// about that backend inconsistency and can just read one field either way.
class GuessResult {
  final bool correct;
  final HigherOrLowerPokemon revealedPokemon;
  final int resultingStreak;

  const GuessResult({
    required this.correct,
    required this.revealedPokemon,
    required this.resultingStreak,
  });

  factory GuessResult.fromJson(Map<String, dynamic> json) {
    final correct = json['correct'] as bool;
    return GuessResult(
      correct: correct,
      revealedPokemon: HigherOrLowerPokemon.fromJson(
        json['revealedPokemon'] as Map<String, dynamic>,
      ),
      resultingStreak: (correct ? json['streak'] : json['finalStreak']) as int,
    );
  }
}
