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
import {
  BattleParticipant,
  TypeClashBattleService,
} from './type-clash-battle.service';
import { TypeClashLobbyService } from './type-clash-lobby.service';
import { TypeClashSelectionService } from './type-clash-selection.service';
import {
  DIFFICULTY_TYPE_COUNT,
  LOBBY_WAIT_SECONDS,
  MIN_PLAYERS_TO_START,
  SELECTION_WAIT_SECONDS,
  TYPE_CLASH_EVENTS,
  TypeClashDifficulty,
} from './types/type-clash.types';

// The client sends only what it legitimately controls (which difficulty,
// which type). WHO the player is comes from their verified token — never
// from the payload.
interface JoinLobbyPayload {
  difficulty: TypeClashDifficulty;
}

interface SelectTypePayload {
  difficulty: TypeClashDifficulty;
  type: string;
}

const VALID_DIFFICULTIES = Object.values(TypeClashDifficulty) as string[];

function isValidDifficulty(value: unknown): value is TypeClashDifficulty {
  return typeof value === 'string' && VALID_DIFFICULTIES.includes(value);
}

// cors: '*' is a dev-only convenience so our Flutter web dev build can
// connect from a different origin. Tighten to a specific origin before
// any real deployment.
@WebSocketGateway({ cors: { origin: '*' } })
export class TypeClashGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(TypeClashGateway.name);

  // In-memory timer handles — fine at a single backend instance. If this
  // ever scaled to multiple instances, "who owns starting the match" would
  // need to move to a Redis-based lock.
  private lobbyTimers = new Map<TypeClashDifficulty, NodeJS.Timeout>();
  private selectionTimers = new Map<TypeClashDifficulty, NodeJS.Timeout>();

  constructor(
    private readonly lobbyService: TypeClashLobbyService,
    private readonly selectionService: TypeClashSelectionService,
    private readonly battleService: TypeClashBattleService,
    private readonly gameScoresService: GameScoresService,
    private readonly wsAuth: WsAuthService,
  ) {}

  // Every socket must present a valid token in its handshake or it is
  // disconnected immediately. (All gateways share one Socket.IO connection,
  // so each gateway runs this check; WsAuthService caches the result.)
  async handleConnection(client: Socket) {
    const user = await this.wsAuth.authenticate(client);
    if (!user) {
      this.logger.warn(`Rejected unauthenticated socket: ${client.id}`);
      client.disconnect(true);
      return;
    }
    this.logger.log(`Client connected: ${client.id} (${user.username})`);
  }

  // If a player closes the app or loses connection mid-lobby, free their
  // slot immediately and notify everyone else — no "ghost player".
  async handleDisconnect(client: Socket) {
    const removed = await this.lobbyService.removePlayerBySocketId(client.id);
    if (removed) {
      this.logger.log(
        `Client disconnected: ${client.id} (removed from ${removed.difficulty} lobby)`,
      );
      await this.broadcastLobbyUpdate(removed.difficulty);
    }
  }

  @SubscribeMessage(TYPE_CLASH_EVENTS.JOIN_LOBBY)
  async onJoinLobby(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: JoinLobbyPayload,
  ) {
    const user = await this.wsAuth.authenticate(client);
    if (!user) {
      client.disconnect(true);
      return;
    }

    // Without this, a client could invent lobbies with arbitrary names.
    if (!isValidDifficulty(payload?.difficulty)) {
      client.emit(TYPE_CLASH_EVENTS.ERROR, {
        message: 'A valid difficulty is required',
      });
      return;
    }

    const { difficulty } = payload;
    const currentPlayers = await this.lobbyService.getLobbyPlayers(difficulty);

    if (currentPlayers.some((p) => p.userId === user.userId)) {
      client.emit(TYPE_CLASH_EVENTS.ERROR, {
        message: 'You are already in this lobby',
      });
      return;
    }

    const maxPlayers = DIFFICULTY_TYPE_COUNT[difficulty];
    if (currentPlayers.length >= maxPlayers) {
      client.emit(TYPE_CLASH_EVENTS.ERROR, {
        message: `This lobby is full (max ${maxPlayers} players for this difficulty)`,
      });
      return;
    }

    await client.join(this.roomName(difficulty));
    await this.lobbyService.addPlayer(difficulty, {
      socketId: client.id,
      userId: user.userId,
      username: user.username,
    });

    await this.broadcastLobbyUpdate(difficulty);
    this.ensureLobbyTimer(difficulty);
  }

  @SubscribeMessage(TYPE_CLASH_EVENTS.SELECT_TYPE)
  async onSelectType(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: SelectTypePayload,
  ) {
    const user = await this.wsAuth.authenticate(client);
    if (!user) {
      client.disconnect(true);
      return;
    }

    if (
      !isValidDifficulty(payload?.difficulty) ||
      typeof payload?.type !== 'string'
    ) {
      client.emit(TYPE_CLASH_EVENTS.ERROR, {
        message: 'difficulty and type are required',
      });
      return;
    }

    const players = await this.lobbyService.getLobbyPlayers(
      payload.difficulty,
    );
    const player = players.find((p) => p.socketId === client.id);
    if (!player) {
      client.emit(TYPE_CLASH_EVENTS.ERROR, {
        message: 'You are not in this lobby',
      });
      return;
    }

    // A client may only claim a type that was actually offered this round —
    // otherwise it could claim any type it likes, like "fire" on an Easy
    // match that never included fire.
    const availableTypes = await this.selectionService.getAvailableTypes(
      payload.difficulty,
    );
    if (!availableTypes.includes(payload.type)) {
      client.emit(TYPE_CLASH_EVENTS.ERROR, {
        message: 'That type is not available right now',
      });
      return;
    }

    const result = await this.selectionService.claimType(
      payload.difficulty,
      payload.type,
      player,
    );

    if (!result.success) {
      client.emit(TYPE_CLASH_EVENTS.ERROR, { message: result.reason });
      return;
    }

    this.server
      .to(this.roomName(payload.difficulty))
      .emit(TYPE_CLASH_EVENTS.TYPE_CLAIMED, {
        type: payload.type,
        username: player.username,
      });
  }

  private roomName(difficulty: TypeClashDifficulty) {
    return `type-clash:${difficulty}`;
  }

  private async broadcastLobbyUpdate(difficulty: TypeClashDifficulty) {
    const players = await this.lobbyService.getLobbyPlayers(difficulty);
    this.server
      .to(this.roomName(difficulty))
      .emit(TYPE_CLASH_EVENTS.LOBBY_UPDATE, { players });
  }

  // Starts a countdown the first time a lobby gets its first player. If a
  // timer is already running for this difficulty, we don't restart it — this
  // gives every player a shared, predictable start time.
  private ensureLobbyTimer(difficulty: TypeClashDifficulty) {
    if (this.lobbyTimers.has(difficulty)) return;

    const timer = setTimeout(async () => {
      this.lobbyTimers.delete(difficulty);
      try {
        const players = await this.lobbyService.getLobbyPlayers(difficulty);

        if (players.length >= MIN_PLAYERS_TO_START) {
          await this.startTypeSelection(difficulty);
        } else {
          this.logger.log(
            `Lobby ${difficulty} timed out with only ${players.length} player(s) — waiting for more`,
          );
          this.ensureLobbyTimer(difficulty);
        }
      } catch (err) {
        // Fire-and-forget timer callbacks aren't part of any request cycle,
        // so Nest's exception filters never see errors thrown here.
        const error = err instanceof Error ? err : new Error(String(err));
        this.logger.error(
          `Lobby timer failed for ${difficulty}: ${error.message}`,
          error.stack,
        );
      }
    }, LOBBY_WAIT_SECONDS * 1000);

    this.lobbyTimers.set(difficulty, timer);
  }

  private async startTypeSelection(difficulty: TypeClashDifficulty) {
    const typeCount = DIFFICULTY_TYPE_COUNT[difficulty];
    const availableTypes = await this.selectionService.startSelection(
      difficulty,
      typeCount,
    );

    this.server
      .to(this.roomName(difficulty))
      .emit(TYPE_CLASH_EVENTS.TYPE_SELECTION_STARTED, {
        availableTypes,
        selectionSeconds: SELECTION_WAIT_SECONDS,
      });

    const timer = setTimeout(async () => {
      this.selectionTimers.delete(difficulty);
      try {
        const players = await this.lobbyService.getLobbyPlayers(difficulty);
        const finalAssignments =
          await this.selectionService.autoAssignRemaining(difficulty, players);

        this.server
          .to(this.roomName(difficulty))
          .emit(TYPE_CLASH_EVENTS.TYPE_SELECTION_COMPLETE, {
            assignments: finalAssignments,
          });

        const participants: BattleParticipant[] = Object.entries(
          finalAssignments,
        ).map(([type, player]) => ({
          type,
          ownerId: player.userId,
          ownerUsername: player.username,
        }));

        const battleResult =
          this.battleService.simulateBubbleBattle(participants);

        this.server
          .to(this.roomName(difficulty))
          .emit(TYPE_CLASH_EVENTS.BATTLE_RESULT, {
            initialBubbles: battleResult.initialBubbles,
            events: battleResult.events,
            winnerType: battleResult.winnerType,
            winnerOwnerUsername: battleResult.winnerOwnerUsername,
          });

        // Awaited sequentially (not Promise.all) deliberately — at max 10
        // players the extra latency is negligible, and sequential writes
        // are simpler to debug if one fails.
        for (const [userId, score] of Object.entries(
          battleResult.scoresByUserId,
        )) {
          await this.gameScoresService.submitScore({
            userId,
            gameType: GameType.TYPE_CLASH,
            mode: GameMode.MULTI,
            score,
          });
        }

        this.logger.log(
          `Battle complete for ${difficulty} lobby — winner: ${battleResult.winnerType ?? 'none'}`,
        );

        // Match is over: empty the lobby and pull every socket out of the
        // room, so nobody receives the NEXT match's events unless they
        // deliberately rejoin ("Play again").
        await this.lobbyService.clearLobby(difficulty);
        this.server
          .in(this.roomName(difficulty))
          .socketsLeave(this.roomName(difficulty));
      } catch (err) {
        const error = err instanceof Error ? err : new Error(String(err));
        this.logger.error(
          `Selection timer failed for ${difficulty}: ${error.message}`,
          error.stack,
        );
      }
    }, SELECTION_WAIT_SECONDS * 1000);

    this.selectionTimers.set(difficulty, timer);
  }
}
