import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import Redis from 'ioredis';
import { GameMode, GameType } from '../game-scores/dto/submit-score.dto';
import { GameScoresService } from '../game-scores/game-scores.service';
import { PokemonService } from '../pokemon/pokemon.service';
import { REDIS_CLIENT } from '../redis/redis.module';
import {
  ComparableStat,
  HigherOrLowerSession,
} from './types/game-session.type';

// 10 minutes — long enough for a real game session, short enough that
// abandoned games don't linger in Redis forever. This IS our timeout
// handling: Redis auto-expires the key, no manual cleanup job needed.
const SESSION_TTL_SECONDS = 60 * 10;

const COMPARABLE_STATS: ComparableStat[] = [
  'hp',
  'attack',
  'defense',
  'specialAttack',
  'specialDefense',
  'speed',
];

// Deliberately identical for "doesn't exist", "expired", and "belongs to
// someone else" — so a caller can't probe which session ids are real.
const SESSION_NOT_FOUND_MESSAGE =
  'Game session not found or expired — please start a new game';

@Injectable()
export class HigherOrLowerService {
  constructor(
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    private readonly pokemonService: PokemonService,
    private readonly gameScoresService: GameScoresService,
  ) {}

  async startGame(userId: string) {
    const statKey = this.pickRandomStat();
    const currentPokemon = await this.pokemonService.getRandomPokemon();

    const sessionId = randomUUID();
    const session: HigherOrLowerSession = {
      userId,
      statKey,
      currentPokemon,
      streak: 0,
    };

    await this.saveSession(sessionId, session);

    return {
      sessionId,
      statKey,
      // Only expose what's needed to render this round — id/name/sprite for
      // display, plus the single stat value being compared. We deliberately
      // do NOT send the Pokémon's other stats.
      pokemon: {
        id: currentPokemon.id,
        name: currentPokemon.name,
        spriteUrl: currentPokemon.spriteUrl,
        statValue: currentPokemon.stats[statKey],
      },
    };
  }

  async submitGuess(
    sessionId: string,
    guess: 'higher' | 'lower',
    userId: string,
  ) {
    const session = await this.loadSession(sessionId);

    // Ownership check: knowing (or guessing) a session id must not let one
    // player play, or end, another player's game.
    if (session.userId !== userId) {
      throw new NotFoundException(SESSION_NOT_FOUND_MESSAGE);
    }

    const nextPokemon = await this.pokemonService.getRandomPokemon();
    const currentValue = session.currentPokemon.stats[session.statKey];
    const nextValue = nextPokemon.stats[session.statKey];

    // A tie counts as automatically correct — a fair rule players expect,
    // rather than failing them on an outcome they couldn't predict.
    const actual: 'higher' | 'lower' | 'tie' =
      nextValue === currentValue
        ? 'tie'
        : nextValue > currentValue
          ? 'higher'
          : 'lower';
    const isCorrect = actual === 'tie' || actual === guess;

    const revealedNext = {
      id: nextPokemon.id,
      name: nextPokemon.name,
      spriteUrl: nextPokemon.spriteUrl,
      statValue: nextValue,
    };

    if (!isCorrect) {
      await this.endSession(sessionId);
      await this.gameScoresService.submitScore({
        userId: session.userId,
        gameType: GameType.HIGHER_OR_LOWER,
        mode: GameMode.SINGLE,
        score: session.streak,
      });

      return {
        correct: false,
        revealedPokemon: revealedNext,
        finalStreak: session.streak,
      };
    }

    const updatedSession: HigherOrLowerSession = {
      ...session,
      currentPokemon: nextPokemon,
      streak: session.streak + 1,
    };
    await this.saveSession(sessionId, updatedSession);

    return {
      correct: true,
      revealedPokemon: revealedNext,
      streak: updatedSession.streak,
    };
  }

  private pickRandomStat(): ComparableStat {
    const index = Math.floor(Math.random() * COMPARABLE_STATS.length);
    return COMPARABLE_STATS[index];
  }

  private async saveSession(sessionId: string, session: HigherOrLowerSession) {
    await this.redis.set(
      this.sessionKey(sessionId),
      JSON.stringify(session),
      'EX',
      SESSION_TTL_SECONDS,
    );
  }

  private async loadSession(sessionId: string): Promise<HigherOrLowerSession> {
    const raw = await this.redis.get(this.sessionKey(sessionId));
    if (!raw) {
      throw new NotFoundException(SESSION_NOT_FOUND_MESSAGE);
    }
    return JSON.parse(raw);
  }

  private async endSession(sessionId: string) {
    await this.redis.del(this.sessionKey(sessionId));
  }

  private sessionKey(sessionId: string): string {
    return `hol-session:${sessionId}`;
  }
}
