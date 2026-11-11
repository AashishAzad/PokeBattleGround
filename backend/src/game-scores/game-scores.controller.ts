import {
  Controller,
  DefaultValuePipe,
  Get,
  Param,
  ParseEnumPipe,
  ParseIntPipe,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GameType } from './dto/submit-score.dto';
import { GameScoresService } from './game-scores.service';

const MAX_LIMIT = 100;

// Read-only. There is deliberately NO endpoint to submit a score: scores
// are written only by the server-side game logic (HigherOrLowerService,
// the Type Clash gateway, etc.) after it has decided the outcome itself.
// A public "submit score" route would let anyone post any score for anyone.
@UseGuards(JwtAuthGuard)
@Controller('game-scores')
export class GameScoresController {
  constructor(private readonly gameScoresService: GameScoresService) {}

  // ParseEnumPipe rejects unknown game types with a clean 400, instead of
  // letting a garbage value reach Postgres and surface as a 500.
  @Get('leaderboard/:gameType')
  getLeaderboard(
    @Param('gameType', new ParseEnumPipe(GameType)) gameType: GameType,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
  ) {
    return this.gameScoresService.getLeaderboardForGame(
      gameType,
      this.clamp(limit),
    );
  }

  @Get('global-ranking')
  getGlobalRanking(
    @Query('limit', new DefaultValuePipe(50), ParseIntPipe) limit: number,
  ) {
    return this.gameScoresService.getGlobalRanking(this.clamp(limit));
  }

  // Caps `limit` so a caller can't request a million rows in one go.
  private clamp(limit: number): number {
    return Math.min(Math.max(limit, 1), MAX_LIMIT);
  }
}
