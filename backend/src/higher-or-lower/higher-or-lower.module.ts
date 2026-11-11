import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { GameScoresModule } from '../game-scores/game-scores.module';
import { PokemonModule } from '../pokemon/pokemon.module';
import { HigherOrLowerController } from './higher-or-lower.controller';
import { HigherOrLowerService } from './higher-or-lower.service';

@Module({
  imports: [AuthModule, PokemonModule, GameScoresModule],
  controllers: [HigherOrLowerController],
  providers: [HigherOrLowerService],
})
export class HigherOrLowerModule {}
