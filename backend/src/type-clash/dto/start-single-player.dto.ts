import { IsEnum, IsIn } from 'class-validator';
import {
  ALL_POKEMON_TYPES,
  TypeClashDifficulty,
} from '../types/type-clash.types';

// No userId field: the player is identified by their verified token.
export class StartSinglePlayerDto {
  @IsEnum(TypeClashDifficulty)
  difficulty: TypeClashDifficulty;

  // Must be one of the 18 real types.
  @IsIn(ALL_POKEMON_TYPES)
  chosenType: string;
}
