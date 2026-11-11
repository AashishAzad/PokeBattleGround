import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { AuthenticatedRequest } from '../auth/types/auth.types';
import { GuessDto } from './dto/guess.dto';
import { HigherOrLowerService } from './higher-or-lower.service';

// WHO is playing comes from the verified token (req.user), never from the
// request body — so a caller can only ever play as themselves.
@UseGuards(JwtAuthGuard)
@Controller('higher-or-lower')
export class HigherOrLowerController {
  constructor(private readonly higherOrLowerService: HigherOrLowerService) {}

  @Post('start')
  start(@Req() req: AuthenticatedRequest) {
    return this.higherOrLowerService.startGame(req.user!.userId);
  }

  @Post('guess')
  guess(@Body() dto: GuessDto, @Req() req: AuthenticatedRequest) {
    return this.higherOrLowerService.submitGuess(
      dto.sessionId,
      dto.guess,
      req.user!.userId,
    );
  }
}
