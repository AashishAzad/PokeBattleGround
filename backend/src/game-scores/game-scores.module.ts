import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { GameScoresController } from './game-scores.controller';
import { GameScoresService } from './game-scores.service';

@Module({
  imports: [AuthModule],
  controllers: [GameScoresController],
  providers: [GameScoresService],
  // Exported so game modules can save scores without duplicating logic.
  exports: [GameScoresService],
})
export class GameScoresModule {}
