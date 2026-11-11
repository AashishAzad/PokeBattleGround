import { Inject, Injectable } from '@nestjs/common';
import Redis from 'ioredis';
import { REDIS_CLIENT } from '../redis/redis.module';
import {
  ALL_POKEMON_TYPES,
  LobbyPlayer,
  TypeClashDifficulty,
} from './types/type-clash.types';

const SELECTION_STATE_TTL_SECONDS = 60 * 5;

// Manages the "type selection" phase: which types are up for grabs, and
// who has claimed which. Every claim goes through Redis's atomic HSETNX
// (set-only-if-not-already-set), because multiple players can click at
// nearly the same instant — we need whichever request arrives first at
// Redis to actually win, not whichever happens to finish processing last
// in our own Node process.
@Injectable()
export class TypeClashSelectionService {
  constructor(@Inject(REDIS_CLIENT) private readonly redis: Redis) {}

  private availableTypesKey(difficulty: TypeClashDifficulty) {
    return `type-clash:selection:${difficulty}:available`;
  }

  private claimsKey(difficulty: TypeClashDifficulty) {
    return `type-clash:selection:${difficulty}:claims`;
  }

  private claimedByKey(difficulty: TypeClashDifficulty) {
    return `type-clash:selection:${difficulty}:claimedBy`;
  }

  async startSelection(
    difficulty: TypeClashDifficulty,
    typeCount: number,
  ): Promise<string[]> {
    const availableTypes = this.pickRandomTypes(typeCount);

    // Clear any stale state from a previous round before starting fresh.
    await this.redis.del(this.claimsKey(difficulty));
    await this.redis.del(this.claimedByKey(difficulty));
    await this.redis.set(
      this.availableTypesKey(difficulty),
      JSON.stringify(availableTypes),
      'EX',
      SELECTION_STATE_TTL_SECONDS,
    );

    return availableTypes;
  }

  async getAvailableTypes(difficulty: TypeClashDifficulty): Promise<string[]> {
    const raw = await this.redis.get(this.availableTypesKey(difficulty));
    return raw ? JSON.parse(raw) : [];
  }

  // Claiming a type has two conditions that both need to hold: the type
  // itself must be unclaimed, AND this player must not have already
  // claimed a different type. We check/reserve both with separate atomic
  // HSETNX calls rather than a single Lua script — simpler to reason
  // about at our scale, with a small compensating rollback for the rare
  // race where two claims land in the same few-millisecond window.
  async claimType(
    difficulty: TypeClashDifficulty,
    type: string,
    player: LobbyPlayer,
  ): Promise<{ success: boolean; reason?: string }> {
    const claimedByKey = this.claimedByKey(difficulty);
    const claimsKey = this.claimsKey(difficulty);

    const reservedOwnClaim = await this.redis.hsetnx(
      claimedByKey,
      player.userId,
      type,
    );
    if (reservedOwnClaim === 0) {
      return { success: false, reason: 'You have already selected a type' };
    }

    const claimedType = await this.redis.hsetnx(
      claimsKey,
      type,
      JSON.stringify(player),
    );
    if (claimedType === 0) {
      // Someone else claimed this exact type in the tiny window between
      // our two checks — roll back so this player can try a different
      // type instead of being permanently locked out for the round.
      await this.redis.hdel(claimedByKey, player.userId);
      return {
        success: false,
        reason: 'That type was just claimed by someone else',
      };
    }

    return { success: true };
  }

  async getClaims(
    difficulty: TypeClashDifficulty,
  ): Promise<Record<string, LobbyPlayer>> {
    const raw = await this.redis.hgetall(this.claimsKey(difficulty));
    const claims: Record<string, LobbyPlayer> = {};
    for (const [type, json] of Object.entries(raw)) {
      claims[type] = JSON.parse(json);
    }
    return claims;
  }

  // Called once the selection timer runs out: any player who never
  // claimed a type gets randomly assigned one of the leftover types.
  async autoAssignRemaining(
    difficulty: TypeClashDifficulty,
    allLobbyPlayers: LobbyPlayer[],
  ): Promise<Record<string, LobbyPlayer>> {
    const availableTypes = await this.getAvailableTypes(difficulty);
    const claims = await this.getClaims(difficulty);

    const claimedTypes = new Set(Object.keys(claims));
    const claimedUserIds = new Set(
      Object.values(claims).map((p) => p.userId),
    );

    const unclaimedTypes = availableTypes.filter((t) => !claimedTypes.has(t));
    const unassignedPlayers = allLobbyPlayers.filter(
      (p) => !claimedUserIds.has(p.userId),
    );

    const shuffledTypes = this.shuffle(unclaimedTypes);

    for (
      let i = 0;
      i < unassignedPlayers.length && i < shuffledTypes.length;
      i++
    ) {
      await this.redis.hset(
        this.claimsKey(difficulty),
        shuffledTypes[i],
        JSON.stringify(unassignedPlayers[i]),
      );
    }

    return this.getClaims(difficulty);
  }

  private pickRandomTypes(count: number): string[] {
    return this.shuffle(ALL_POKEMON_TYPES).slice(0, count);
  }

  // Fisher-Yates shuffle — an actual unbiased shuffle, unlike the common
  // `array.sort(() => Math.random() - 0.5)` trick, which is well-known to
  // produce statistically skewed orderings.
  private shuffle<T>(items: T[]): T[] {
    const copy = [...items];
    for (let i = copy.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [copy[i], copy[j]] = [copy[j], copy[i]];
    }
    return copy;
  }
}
