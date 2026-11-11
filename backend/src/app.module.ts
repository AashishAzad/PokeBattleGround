import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { DatabaseModule } from './database/database.module';
import { GameScoresModule } from './game-scores/game-scores.module';
import { HigherOrLowerModule } from './higher-or-lower/higher-or-lower.module';
import { PokemonModule } from './pokemon/pokemon.module';
import { RedisModule } from './redis/redis.module';
import { TypeClashModule } from './type-clash/type-clash.module';
import { UsersModule } from './users/users.module';
import { WhoIsThatPokemonModule } from './who-is-that-pokemon/who-is-that-pokemon.module';

@Module({
  imports: [
    // isGlobal: true means every other module can inject ConfigService
    // without re-importing ConfigModule.
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    RedisModule,
    UsersModule,
    PokemonModule,
    GameScoresModule,
    HigherOrLowerModule,
    TypeClashModule,
    WhoIsThatPokemonModule,
    AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
