import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { UsersModule } from '../users/users.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt-auth.guard';
import { PasswordService } from './password.service';
import { WsAuthService } from './ws-auth.service';

const SEVEN_DAYS_IN_SECONDS = 60 * 60 * 24 * 7;

@Module({
  imports: [
    UsersModule,
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        // getOrThrow: the app refuses to boot without a secret, rather than
        // silently signing tokens with an undefined/empty one.
        secret: config.getOrThrow<string>('JWT_SECRET'),
        signOptions: { expiresIn: SEVEN_DAYS_IN_SECONDS },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, PasswordService, JwtAuthGuard, WsAuthService],
  // Every module with a guarded controller or an authenticated gateway
  // imports AuthModule to get these.
  exports: [JwtAuthGuard, JwtModule, WsAuthService],
})
export class AuthModule {}
