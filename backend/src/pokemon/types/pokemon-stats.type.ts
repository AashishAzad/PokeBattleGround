// Our own internal shape for a Pokémon, deliberately independent of
// PokeAPI's raw (deeply nested) response format. Every game module depends
// on THIS type, never on PokeAPI's response shape directly — that's what
// makes PokemonService swappable/mockable later.
export interface PokemonSummary {
  id: number;
  name: string;
  spriteUrl: string;
  types: string[];
  stats: {
    hp: number;
    attack: number;
    defense: number;
    specialAttack: number;
    specialDefense: number;
    speed: number;
  };
}
