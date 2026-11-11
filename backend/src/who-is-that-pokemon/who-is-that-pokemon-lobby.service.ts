import { Inject, Injectable } from '@nestjs/common';
import Redis from 'ioredis';
import { REDIS_CLIENT } from '../redis/redis.module';
import { LobbyPlayer } from './types/who-is-that-pokemon.types';

const LOBBY_KEY = 'witp:lobby';
const SOCKET_LOOKUP_PREFIX = 'witp:socket:';

@Injectable()
export class WhoIsThatPokemonLobbyService {
  constructor(@Inject(REDIS_CLIENT) private readonly redis: Redis) {}

  async addPlayer(player: LobbyPlayer) {
    await this.redis.hset(LOBBY_KEY, player.socketId, JSON.stringify(player));
    await this.redis.expire(LOBBY_KEY, 60 * 60);
    await this.redis.set(
      `${SOCKET_LOOKUP_PREFIX}${player.socketId}`,
      '1',
      'EX',
      60 * 60,
    );
  }

  async removePlayerBySocketId(socketId: string): Promise<LobbyPlayer | null> {
    const raw = await this.redis.hget(LOBBY_KEY, socketId);
    if (!raw) return null;
    await this.redis.hdel(LOBBY_KEY, socketId);
    await this.redis.del(`${SOCKET_LOOKUP_PREFIX}${socketId}`);
    return JSON.parse(raw);
  }

  async getPlayers(): Promise<LobbyPlayer[]> {
    const entries = await this.redis.hvals(LOBBY_KEY);
    return entries.map((e) => JSON.parse(e));
  }

  // Called once a match finishes, so the next group of players starts
  // from a clean lobby rather than inheriting stale entries.
  async clearLobby() {
    await this.redis.del(LOBBY_KEY);
  }
}
