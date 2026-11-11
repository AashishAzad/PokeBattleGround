import { Injectable } from '@nestjs/common';
import { GameMode, GameType } from '../game-scores/dto/submit-score.dto';
import { GameScoresService } from '../game-scores/game-scores.service';
import {
  BattleParticipant,
  TypeClashBattleService,
} from './type-clash-battle.service';
import {
  ALL_POKEMON_TYPES,
  DIFFICULTY_TYPE_COUNT,
  TypeClashDifficulty,
} from './types/type-clash.types';

// Single-player reuses the exact same battle engine as multiplayer — the
// only difference is where the OTHER participants come from: real players
// claiming types via WebSocket, versus randomly picked computer opponents
// here. This is why TypeClashBattleService takes a generic
// BattleParticipant[] rather than anything lobby-specific.
@Injectable()
export class TypeClashSinglePlayerService {
  constructor(
    private readonly battleService: TypeClashBattleService,
    private readonly gameScoresService: GameScoresService,
  ) {}

  async startSinglePlayerBattle(
    userId: string,
    difficulty: TypeClashDifficulty,
    chosenType: string,
  ) {
    const totalTypes = DIFFICULTY_TYPE_COUNT[difficulty];
    const botTypes = this.pickRandomOtherTypes(chosenType, totalTypes - 1);

    const participants: BattleParticipant[] = [
      { type: chosenType, ownerId: userId, ownerUsername: null },
      ...botTypes.map((type) => ({
        type,
        ownerId: null,
        ownerUsername: null,
      })),
    ];

    const result = this.battleService.simulateBubbleBattle(participants);

    const myScore = result.scoresByUserId[userId] ?? 0;
    await this.gameScoresService.submitScore({
      userId,
      gameType: GameType.TYPE_CLASH,
      mode: GameMode.SINGLE,
      score: myScore,
    });

    return result;
  }

  private pickRandomOtherTypes(exclude: string, count: number): string[] {
    const pool = ALL_POKEMON_TYPES.filter((t) => t !== exclude);
    return this.shuffle(pool).slice(0, count);
  }

  private shuffle<T>(items: T[]): T[] {
    const copy = [...items];
    for (let i = copy.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [copy[i], copy[j]] = [copy[j], copy[i]];
    }
    return copy;
  }
}
