import { Inject, Injectable } from '@nestjs/common';
import Redis from 'ioredis';
import { REDIS_CLIENT } from '../redis/redis.module';
import { LobbyPlayer, TypeClashDifficulty } from './types/type-clash.types';

// All lobby membership lives in Redis, not in-memory on the Nest process.
// If we ever run multiple backend instances behind a load balancer, an
// in-memory array on one instance would be invisible to a Socket.IO
// connection that lands on another. Redis is the single shared source of truth.
@Injectable()
export class TypeClashLobbyService {
  constructor(@Inject(REDIS_CLIENT) private readonly redis: Redis) {}

  private lobbyKey(difficulty: TypeClashDifficulty) {
    return `type-clash:lobby:${difficulty}`;
  }

  // Reverse lookup so handleDisconnect can find which lobby+player to
  // remove using only the disconnecting socket's id.
  private socketLookupKey(socketId: string) {
    return `type-clash:socket:${socketId}`;
  }

  async addPlayer(difficulty: TypeClashDifficulty, player: LobbyPlayer) {
    await this.redis.hset(
      this.lobbyKey(difficulty),
      player.socketId,
      JSON.stringify(player),
    );
    // TTL as a safety net — if a lobby is somehow never cleaned up, Redis
    // reclaims it after an hour instead of the entry living forever.
    await this.redis.expire(this.lobbyKey(difficulty), 60 * 60);

    await this.redis.set(
      this.socketLookupKey(player.socketId),
      difficulty,
      'EX',
      60 * 60,
    );
  }

  async removePlayerBySocketId(socketId: string): Promise<{
    difficulty: TypeClashDifficulty;
    player: LobbyPlayer;
  } | null> {
    const difficulty = (await this.redis.get(
      this.socketLookupKey(socketId),
    )) as TypeClashDifficulty | null;
    if (!difficulty) return null;

    const raw = await this.redis.hget(this.lobbyKey(difficulty), socketId);
    if (!raw) return null;

    await this.redis.hdel(this.lobbyKey(difficulty), socketId);
    await this.redis.del(this.socketLookupKey(socketId));

    return { difficulty, player: JSON.parse(raw) };
  }

  async getLobbyPlayers(
    difficulty: TypeClashDifficulty,
  ): Promise<LobbyPlayer[]> {
    const entries = await this.redis.hvals(this.lobbyKey(difficulty));
    return entries.map((e) => JSON.parse(e));
  }

  // Called once a match finishes, so the next group starts from a clean
  // lobby instead of inheriting players from the previous match.
  async clearLobby(difficulty: TypeClashDifficulty) {
    const players = await this.getLobbyPlayers(difficulty);
    await Promise.all(
      players.map((p) => this.redis.del(this.socketLookupKey(p.socketId))),
    );
    await this.redis.del(this.lobbyKey(difficulty));
  }
}
