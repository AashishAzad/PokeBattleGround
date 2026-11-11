import { IsString, MaxLength } from 'class-validator';

export class LoginDto {
  @IsString()
  @MaxLength(32)
  username: string;

  @IsString()
  @MaxLength(128)
  password: string;
}
