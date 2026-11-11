import { Inject, Injectable, Logger } from '@nestjs/common';
import Redis from 'ioredis';
import { REDIS_CLIENT } from '../redis/redis.module';
import { PokemonSummary } from './types/pokemon-stats.type';

const POKEAPI_BASE_URL = 'https://pokeapi.co/api/v2';

// Pokémon data is effectively static, so a long TTL just protects us from
// re-fetching the same data repeatedly — not a correctness concern here.
const CACHE_TTL_SECONDS = 60 * 60 * 24; // 24 hours

// As of PokeAPI's current dataset (Gen 1–9). Update this if a new
// generation gets added and you want it in the random pool.
const TOTAL_POKEMON_COUNT = 1025;

@Injectable()
export class PokemonService {
  private readonly logger = new Logger(PokemonService.name);

  constructor(@Inject(REDIS_CLIENT) private readonly redis: Redis) {}

  async getPokemonById(id: number): Promise<PokemonSummary> {
    const cacheKey = `pokemon:${id}`;

    const cached = await this.redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }

    const response = await fetch(`${POKEAPI_BASE_URL}/pokemon/${id}`);
    if (!response.ok) {
      throw new Error(
        `PokeAPI request failed for id ${id}: ${response.status}`,
      );
    }

    const raw = await response.json();
    const summary = this.mapToSummary(raw);

    // Fire-and-forget cache write — if this fails, the only consequence is
    // we hit PokeAPI again next time, not a broken request right now.
    this.redis
      .set(cacheKey, JSON.stringify(summary), 'EX', CACHE_TTL_SECONDS)
      .catch((err) => {
        this.logger.warn(`Failed to cache pokemon:${id} — ${err.message}`);
      });

    return summary;
  }

  async getRandomPokemon(): Promise<PokemonSummary> {
    const randomId = Math.floor(Math.random() * TOTAL_POKEMON_COUNT) + 1;
    return this.getPokemonById(randomId);
  }

  // Translates PokeAPI's raw, deeply-nested response into our own clean
  // PokemonSummary type. This is the ONLY place in the codebase that knows
  // what PokeAPI's response looks like.
  private mapToSummary(raw: any): PokemonSummary {
    const findStat = (statName: string): number =>
      raw.stats.find((s: any) => s.stat.name === statName)?.base_stat ?? 0;

    return {
      id: raw.id,
      name: raw.name,
      spriteUrl:
        raw.sprites?.other?.['official-artwork']?.front_default ??
        raw.sprites?.front_default,
      types: raw.types.map((t: any) => t.type.name),
      stats: {
        hp: findStat('hp'),
        attack: findStat('attack'),
        defense: findStat('defense'),
        specialAttack: findStat('special-attack'),
        specialDefense: findStat('special-defense'),
        speed: findStat('speed'),
      },
    };
  }
}
