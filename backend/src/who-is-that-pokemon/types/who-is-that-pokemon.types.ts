export const MAX_PLAYERS = 4;
export const MIN_PLAYERS_TO_START = 2;
export const LOBBY_WAIT_SECONDS = 20;
export const ROUND_DURATION_SECONDS = 10;
export const ROUNDS_PER_MATCH = 5;

export interface LobbyPlayer {
  socketId: string;
  userId: string;
  username: string;
}

export const WHO_IS_THAT_EVENTS = {
  JOIN_LOBBY: 'whoIsThat:joinLobby',
  LOBBY_UPDATE: 'whoIsThat:lobbyUpdate',
  ROUND_START: 'whoIsThat:roundStart',
  GUESS: 'whoIsThat:guess',
  GUESS_RESULT: 'whoIsThat:guessResult',
  CORRECT_GUESS: 'whoIsThat:correctGuess',
  ROUND_END: 'whoIsThat:roundEnd',
  MATCH_END: 'whoIsThat:matchEnd',
  ERROR: 'whoIsThat:error',
} as const;
