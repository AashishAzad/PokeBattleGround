import { PokemonSummary } from '../../pokemon/types/pokemon-stats.type';

// The specific numeric stat we're comparing this round (e.g. "attack", "speed").
export type ComparableStat = keyof PokemonSummary['stats'];

// What we persist in Redis between requests for one in-progress game.
// Kept minimal — just enough to validate the next guess and know the streak.
// This never touches Postgres; only the FINAL score gets written there
// once the game ends (see HigherOrLowerService.submitGuess).
export interface HigherOrLowerSession {
  userId: string;
  statKey: ComparableStat;
  currentPokemon: PokemonSummary;
  streak: number;
}
