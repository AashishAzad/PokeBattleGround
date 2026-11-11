import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { PasswordService } from './password.service';
import type { JwtPayload } from './types/auth.types';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly passwordService: PasswordService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const passwordHash = await this.passwordService.hash(dto.password);
    const user = await this.usersService.createWithPassword(
      dto.username,
      passwordHash,
    );

    return this.buildAuthResponse(user.id, user.username);
  }

  async login(dto: LoginDto) {
    const record = await this.usersService.findAuthRecordByUsername(
      dto.username,
    );

    // Unknown user and wrong password produce the exact same error —
    // otherwise login would double as a tool for discovering which
    // usernames exist.
    const valid =
      record?.passwordHash != null &&
      (await this.passwordService.verify(dto.password, record.passwordHash));

    if (!record || !valid) {
      throw new UnauthorizedException('Invalid username or password');
    }

    return this.buildAuthResponse(record.id, record.username);
  }

  async getProfile(userId: string) {
    return this.usersService.findOne(userId);
  }

  private async buildAuthResponse(userId: string, username: string) {
    const payload: JwtPayload = { sub: userId, username };
    const accessToken = await this.jwtService.signAsync(payload);

    return {
      accessToken,
      user: { id: userId, username },
    };
  }
}
