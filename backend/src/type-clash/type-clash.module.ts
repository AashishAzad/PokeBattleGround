import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { GameScoresModule } from '../game-scores/game-scores.module';
import { TypeClashBattleService } from './type-clash-battle.service';
import { TypeClashLobbyService } from './type-clash-lobby.service';
import { TypeClashSelectionService } from './type-clash-selection.service';
import { TypeClashSinglePlayerController } from './type-clash-single-player.controller';
import { TypeClashSinglePlayerService } from './type-clash-single-player.service';
import { TypeClashGateway } from './type-clash.gateway';

@Module({
  // AuthModule: the single-player controller's guard and the gateway's
  // WsAuthService. GameScoresModule: saving scores after a battle.
  imports: [AuthModule, GameScoresModule],
  controllers: [TypeClashSinglePlayerController],
  providers: [
    TypeClashGateway,
    TypeClashLobbyService,
    TypeClashSelectionService,
    TypeClashBattleService,
    TypeClashSinglePlayerService,
  ],
})
export class TypeClashModule {}
