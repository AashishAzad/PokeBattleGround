// Difficulty determines how many distinct Pokémon types are in play:
// Easy=3, Medium=6, Hard=10.
export enum TypeClashDifficulty {
  EASY = 'easy',
  MEDIUM = 'medium',
  HARD = 'hard',
}

export const DIFFICULTY_TYPE_COUNT: Record<TypeClashDifficulty, number> = {
  [TypeClashDifficulty.EASY]: 3,
  [TypeClashDifficulty.MEDIUM]: 6,
  [TypeClashDifficulty.HARD]: 10,
};

// Minimum players needed before a lobby is allowed to start, even once its
// timer runs out — a "clash" needs at least 2 competitors to mean anything.
export const MIN_PLAYERS_TO_START = 2;

// How long a lobby waits for players to join before starting anyway
// (assuming MIN_PLAYERS_TO_START has already been met).
export const LOBBY_WAIT_SECONDS = 20;

// How long players get to claim a type before leftovers are auto-assigned.
export const SELECTION_WAIT_SECONDS = 15;

// The 18 canonical Pokémon types we draw from when building a lobby's
// available-types pool.
export const ALL_POKEMON_TYPES = [
  'normal',
  'fire',
  'water',
  'electric',
  'grass',
  'ice',
  'fighting',
  'poison',
  'ground',
  'flying',
  'psychic',
  'bug',
  'rock',
  'ghost',
  'dragon',
  'dark',
  'steel',
  'fairy',
];

export interface LobbyPlayer {
  socketId: string;
  userId: string;
  username: string;
}

// Socket.IO event names, centralized here so server handlers and the
// Flutter client reference the same strings instead of duplicating magic
// strings that can silently drift out of sync.
export const TYPE_CLASH_EVENTS = {
  JOIN_LOBBY: 'typeClash:joinLobby',
  LOBBY_UPDATE: 'typeClash:lobbyUpdate',
  TYPE_SELECTION_STARTED: 'typeClash:typeSelectionStarted',
  SELECT_TYPE: 'typeClash:selectType',
  TYPE_CLAIMED: 'typeClash:typeClaimed',
  TYPE_SELECTION_COMPLETE: 'typeClash:typeSelectionComplete',
  BATTLE_RESULT: 'typeClash:battleResult',
  ERROR: 'typeClash:error',
} as const;
