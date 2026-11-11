import { Inject, Injectable } from '@nestjs/common';
import Redis from 'ioredis';
import { PokemonService } from '../pokemon/pokemon.service';
import { REDIS_CLIENT } from '../redis/redis.module';
import { ROUND_DURATION_SECONDS } from './types/who-is-that-pokemon.types';

const CURRENT_ROUND_KEY = 'witp:currentRound';
const CORRECT_GUESSERS_KEY = 'witp:correctGuessers';

interface CurrentRound {
  pokemonId: number;
  pokemonName: string;
  spriteUrl: string;
  startedAt: number; // epoch ms
}

@Injectable()
export class WhoIsThatPokemonRoundService {
  constructor(
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    private readonly pokemonService: PokemonService,
  ) {}

  async startRound(): Promise<{
    pokemonId: number;
    spriteUrl: string;
    durationSeconds: number;
  }> {
    const pokemon = await this.pokemonService.getRandomPokemon();
    const round: CurrentRound = {
      pokemonId: pokemon.id,
      pokemonName: pokemon.name,
      spriteUrl: pokemon.spriteUrl,
      startedAt: Date.now(),
    };

    await this.redis.set(
      CURRENT_ROUND_KEY,
      JSON.stringify(round),
      'EX',
      ROUND_DURATION_SECONDS + 30,
    );
    await this.redis.del(CORRECT_GUESSERS_KEY);

    // pokemonName is deliberately withheld from the return value — only
    // the sprite goes out to clients, so the blur/clarity effect is the
    // only clue, never the answer itself leaking through the payload.
    return {
      pokemonId: pokemon.id,
      spriteUrl: pokemon.spriteUrl,
      durationSeconds: ROUND_DURATION_SECONDS,
    };
  }

  async submitGuess(
    userId: string,
    guess: string,
  ): Promise<{ correct: boolean; alreadyGuessed: boolean; score: number }> {
    const raw = await this.redis.get(CURRENT_ROUND_KEY);
    if (!raw) return { correct: false, alreadyGuessed: false, score: 0 };

    const round: CurrentRound = JSON.parse(raw);

    const alreadyGuessed =
      (await this.redis.sismember(CORRECT_GUESSERS_KEY, userId)) === 1;
    if (alreadyGuessed) {
      return { correct: false, alreadyGuessed: true, score: 0 };
    }

    const isCorrect =
      guess.trim().toLowerCase() === round.pokemonName.toLowerCase();
    if (!isCorrect) {
      return { correct: false, alreadyGuessed: false, score: 0 };
    }

    // SADD returns 1 only the first time this userId is added to the set —
    // this is what guarantees a player can score at most once per round,
    // even if their client somehow fires the guess event twice in a race.
    const added = await this.redis.sadd(CORRECT_GUESSERS_KEY, userId);
    if (added === 0) {
      return { correct: false, alreadyGuessed: true, score: 0 };
    }

    const elapsedSeconds = (Date.now() - round.startedAt) / 1000;
    const fraction = Math.max(0, 1 - elapsedSeconds / ROUND_DURATION_SECONDS);
    // Earlier guesses score higher; a floor of 10 points for any correct
    // guess landed before time runs out, so even a last-second correct
    // guess still feels worth something.
    const score = Math.max(10, Math.round(fraction * 100));

    return { correct: true, alreadyGuessed: false, score };
  }

  async endRound(): Promise<string | null> {
    const raw = await this.redis.get(CURRENT_ROUND_KEY);
    if (!raw) return null;
    const round: CurrentRound = JSON.parse(raw);
    await this.redis.del(CURRENT_ROUND_KEY);
    return round.pokemonName;
  }
}
