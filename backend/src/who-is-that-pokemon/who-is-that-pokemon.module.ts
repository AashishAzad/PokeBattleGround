import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { GameScoresModule } from '../game-scores/game-scores.module';
import { PokemonModule } from '../pokemon/pokemon.module';
import { WhoIsThatPokemonLobbyService } from './who-is-that-pokemon-lobby.service';
import { WhoIsThatPokemonRoundService } from './who-is-that-pokemon-round.service';
import { WhoIsThatPokemonGateway } from './who-is-that-pokemon.gateway';

@Module({
  // AuthModule provides WsAuthService, which the gateway uses to verify
  // every socket's token.
  imports: [AuthModule, PokemonModule, GameScoresModule],
  providers: [
    WhoIsThatPokemonGateway,
    WhoIsThatPokemonLobbyService,
    WhoIsThatPokemonRoundService,
  ],
})
export class WhoIsThatPokemonModule {}
