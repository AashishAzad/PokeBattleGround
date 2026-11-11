import { IsEnum, IsInt, IsUUID, Min } from 'class-validator';

// Mirrors the `game_type` Postgres enum in schema.ts. Kept as a TS enum
// (rather than raw strings) so code gets autocomplete and compile-time
// checking instead of typo-prone magic strings.
export enum GameType {
  HIGHER_OR_LOWER = 'higher_or_lower',
  TYPE_CLASH = 'type_clash',
  WHO_IS_THAT_POKEMON = 'who_is_that_pokemon',
}

// Mirrors the `game_mode` Postgres enum in schema.ts.
export enum GameMode {
  SINGLE = 'single',
  MULTI = 'multi',
}

// Used INTERNALLY by game modules when saving a score. There is no HTTP
// endpoint that accepts this from a client — scores are only ever written
// by server-side game logic after it has decided the outcome itself.
export class SubmitScoreDto {
  @IsUUID()
  userId: string;

  @IsEnum(GameType)
  gameType: GameType;

  @IsEnum(GameMode)
  mode: GameMode;

  @IsInt()
  @Min(0)
  score: number;
}
