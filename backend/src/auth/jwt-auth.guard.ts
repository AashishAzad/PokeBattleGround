import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { AuthenticatedRequest, JwtPayload } from './types/auth.types';

// Apply with @UseGuards(JwtAuthGuard) on any route that requires login.
// On success it attaches `request.user`, so controllers can read WHO is
// calling from a verified token instead of trusting an id in the body.
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const token = this.extractBearerToken(request);
    if (!token) {
      throw new UnauthorizedException('Missing access token');
    }

    try {
      const payload = await this.jwtService.verifyAsync<JwtPayload>(token);
      request.user = { userId: payload.sub, username: payload.username };
      return true;
    } catch {
      // Same message for bad signature, tampering, and expiry — don't tell
      // a caller which one it was.
      throw new UnauthorizedException('Invalid or expired access token');
    }
  }

  private extractBearerToken(request: AuthenticatedRequest): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
