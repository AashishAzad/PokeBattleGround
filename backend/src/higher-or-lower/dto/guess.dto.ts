import { IsIn, IsString } from 'class-validator';

export class GuessDto {
  @IsString()
  sessionId: string;

  @IsIn(['higher', 'lower'])
  guess: 'higher' | 'lower';
}
