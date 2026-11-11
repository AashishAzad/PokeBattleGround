import { Logger } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { WsAuthService } from '../auth/ws-auth.service';
import { GameMode, GameType } from '../game-scores/dto/submit-score.dto';
import { GameScoresService } from '../game-scores/game-scores.service';
import { WhoIsThatPokemonLobbyService } from './who-is-that-pokemon-lobby.service';
import { WhoIsThatPokemonRoundService } from './who-is-that-pokemon-round.service';
import {
  LOBBY_WAIT_SECONDS,
  LobbyPlayer,
  MAX_PLAYERS,
  MIN_PLAYERS_TO_START,
  ROUNDS_PER_MATCH,
  WHO_IS_THAT_EVENTS,
} from './types/who-is-that-pokemon.types';

const ROOM_NAME = 'who-is-that-pokemon';
// Pause between rounds so players have a moment to read the reveal before
// the next Pokémon starts.
const INTER_ROUND_PAUSE_MS = 2500;

interface GuessPayload {
  guess: string;
}

@WebSocketGateway({ cors: { origin: '*' } })
export class WhoIsThatPokemonGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(WhoIsThatPokemonGateway.name);

  private lobbyTimer: NodeJS.Timeout | null = null;
  private matchInProgress = false;
  private matchScores = new Map<
    string,
    { username: string; score: number }
  >();

  constructor(
    private readonly lobbyService: WhoIsThatPokemonLobbyService,
    private readonly roundService: WhoIsThatPokemonRoundService,
    private readonly gameScoresService: GameScoresService,
    private readonly wsAuth: WsAuthService,
  ) {}

  // Every socket must present a valid token in its handshake or it is
  // disconnected immediately.
  async handleConnection(client: Socket) {
    const user = await this.wsAuth.authenticate(client);
    if (!user) {
      this.logger.warn(`Rejected unauthenticated socket: ${client.id}`);
      client.disconnect(true);
      return;
    }
    this.logger.log(`Client connected: ${client.id} (${user.username})`);
  }

  async handleDisconnect(client: Socket) {
    const removed = await this.lobbyService.removePlayerBySocketId(client.id);
    if (removed) {
      this.logger.log(`Client disconnected: ${client.id}`);
      await this.broadcastLobbyUpdate();
    }
  }

  @SubscribeMessage(WHO_IS_THAT_EVENTS.JOIN_LOBBY)
  async onJoinLobby(@ConnectedSocket() client: Socket) {
    // WHO is joining comes from the verified token, not from the payload.
    const user = await this.wsAuth.authenticate(client);
    if (!user) {
      client.disconnect(true);
      return;
    }

    if (this.matchInProgress) {
      client.emit(WHO_IS_THAT_EVENTS.ERROR, {
        message: 'A match is already in progress — try again shortly',
      });
      return;
    }

    const currentPlayers = await this.lobbyService.getPlayers();
    if (currentPlayers.some((p) => p.userId === user.userId)) {
      client.emit(WHO_IS_THAT_EVENTS.ERROR, {
        message: 'You are already in this lobby',
      });
      return;
    }

    if (currentPlayers.length >= MAX_PLAYERS) {
      client.emit(WHO_IS_THAT_EVENTS.ERROR, {
        message: `Lobby is full (max ${MAX_PLAYERS} players)`,
      });
      return;
    }

    await client.join(ROOM_NAME);
    await this.lobbyService.addPlayer({
      socketId: client.id,
      userId: user.userId,
      username: user.username,
    });

    await this.broadcastLobbyUpdate();
    this.ensureLobbyTimer();
  }

  @SubscribeMessage(WHO_IS_THAT_EVENTS.GUESS)
  async onGuess(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: GuessPayload,
  ) {
    const players = await this.lobbyService.getPlayers();
    const player = players.find((p) => p.socketId === client.id);
    if (
      !player ||
      typeof payload?.guess !== 'string' ||
      payload.guess.length === 0 ||
      payload.guess.length > 64
    ) {
      return;
    }

    const result = await this.roundService.submitGuess(
      player.userId,
      payload.guess,
    );

    // Private ack to the guesser only — other players shouldn't see wrong
    // guesses, and the correct answer text itself is never broadcast
    // mid-round (CORRECT_GUESS below announces WHO got it, not WHAT the
    // answer was — that only comes out in ROUND_END).
    client.emit(WHO_IS_THAT_EVENTS.GUESS_RESULT, {
      correct: result.correct,
      alreadyGuessed: result.alreadyGuessed,
      score: result.score,
    });

    if (result.correct) {
      const current = this.matchScores.get(player.userId) ?? {
        username: player.username,
        score: 0,
      };
      current.score += result.score;
      this.matchScores.set(player.userId, current);

      this.server.to(ROOM_NAME).emit(WHO_IS_THAT_EVENTS.CORRECT_GUESS, {
        username: player.username,
        roundScore: result.score,
      });
    }
  }

  private async broadcastLobbyUpdate() {
    const players = await this.lobbyService.getPlayers();
    this.server
      .to(ROOM_NAME)
      .emit(WHO_IS_THAT_EVENTS.LOBBY_UPDATE, { players });
  }

  private ensureLobbyTimer() {
    if (this.lobbyTimer) return;

    this.lobbyTimer = setTimeout(async () => {
      this.lobbyTimer = null;
      try {
        const players = await this.lobbyService.getPlayers();
        if (players.length >= MIN_PLAYERS_TO_START) {
          await this.runMatch(players);
        } else {
          this.logger.log(
            `Who Is That Pokémon lobby timed out with only ${players.length} player(s) — waiting for more`,
          );
          this.ensureLobbyTimer();
        }
      } catch (err) {
        const error = err instanceof Error ? err : new Error(String(err));
        this.logger.error(`Lobby timer failed: ${error.message}`, error.stack);
      }
    }, LOBBY_WAIT_SECONDS * 1000);
  }

  private async runMatch(players: LobbyPlayer[]) {
    this.matchInProgress = true;
    this.matchScores = new Map(
      players.map((p) => [p.userId, { username: p.username, score: 0 }]),
    );

    for (
      let roundNumber = 1;
      roundNumber <= ROUNDS_PER_MATCH;
      roundNumber++
    ) {
      const round = await this.roundService.startRound();

      this.server.to(ROOM_NAME).emit(WHO_IS_THAT_EVENTS.ROUND_START, {
        pokemonId: round.pokemonId,
        spriteUrl: round.spriteUrl,
        durationSeconds: round.durationSeconds,
        roundNumber,
        totalRounds: ROUNDS_PER_MATCH,
      });

      await this.delay(round.durationSeconds * 1000);

      const pokemonName = await this.roundService.endRound();
      this.server.to(ROOM_NAME).emit(WHO_IS_THAT_EVENTS.ROUND_END, {
        pokemonName,
        roundNumber,
      });

      await this.delay(INTER_ROUND_PAUSE_MS);
    }

    const finalScores = [...this.matchScores.entries()].map(
      ([userId, data]) => ({
        userId,
        username: data.username,
        score: data.score,
      }),
    );

    this.server
      .to(ROOM_NAME)
      .emit(WHO_IS_THAT_EVENTS.MATCH_END, { finalScores });

    for (const entry of finalScores) {
      await this.gameScoresService.submitScore({
        userId: entry.userId,
        gameType: GameType.WHO_IS_THAT_POKEMON,
        mode: GameMode.MULTI,
        score: entry.score,
      });
    }

    this.logger.log(
      `Who Is That Pokémon match complete — ${finalScores.length} players scored`,
    );

    await this.lobbyService.clearLobby();
    this.server.in(ROOM_NAME).socketsLeave(ROOM_NAME);
    this.matchInProgress = false;
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
