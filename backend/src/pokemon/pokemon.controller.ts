import { Controller, Get, Param, ParseIntPipe, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PokemonService } from './pokemon.service';

@UseGuards(JwtAuthGuard)
@Controller('pokemon')
export class PokemonController {
  constructor(private readonly pokemonService: PokemonService) {}

  @Get('random')
  getRandom() {
    return this.pokemonService.getRandomPokemon();
  }

  @Get(':id')
  getById(@Param('id', ParseIntPipe) id: number) {
    return this.pokemonService.getPokemonById(id);
  }
}
