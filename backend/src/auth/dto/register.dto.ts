import { IsString, Length, Matches } from 'class-validator';

export class RegisterDto {
  @IsString()
  @Length(3, 32, { message: 'Username must be between 3 and 32 characters' })
  @Matches(/^[a-zA-Z0-9_]+$/, {
    message: 'Username can only contain letters, numbers, and underscores',
  })
  username: string;

  // Upper bound matters too: hashing is deliberately expensive, so without
  // a cap, someone could submit a megabyte-long "password" to burn CPU.
  @IsString()
  @Length(8, 128, { message: 'Password must be between 8 and 128 characters' })
  password: string;
}
