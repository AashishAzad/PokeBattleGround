import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import type { AuthenticatedRequest } from '../auth/types/auth.types';
import { StartSinglePlayerDto } from './dto/start-single-player.dto';
import { TypeClashSinglePlayerService } from './type-clash-single-player.service';

@UseGuards(JwtAuthGuard)
@Controller('type-clash/single-player')
export class TypeClashSinglePlayerController {
  constructor(
    private readonly singlePlayerService: TypeClashSinglePlayerService,
  ) {}

  @Post('start')
  start(
    @Body() dto: StartSinglePlayerDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.singlePlayerService.startSinglePlayerBattle(
      req.user!.userId,
      dto.difficulty,
      dto.chosenType,
    );
  }
}
