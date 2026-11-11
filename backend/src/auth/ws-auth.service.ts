import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { Socket } from 'socket.io';
import type { AuthenticatedUser, JwtPayload } from './types/auth.types';

// WebSocket equivalent of JwtAuthGuard. A browser/Flutter socket can't send
// an Authorization header on the WebSocket upgrade, so the client passes its
// token in Socket.IO's handshake `auth` payload instead. We verify it here
// and cache the result on the socket (client.data), so every gateway handler
// can call authenticate() freely — it's idempotent and cheap after the first
// call. Handlers call this themselves rather than assuming handleConnection
// already finished, because Nest doesn't guarantee that ordering.
@Injectable()
export class WsAuthService {
  constructor(private readonly jwtService: JwtService) {}

  async authenticate(client: Socket): Promise<AuthenticatedUser | null> {
    const cached = client.data.user as AuthenticatedUser | undefined;
    if (cached) return cached;

    const token: unknown = client.handshake.auth?.token;
    if (typeof token !== 'string' || token.length === 0) return null;

    try {
      const payload = await this.jwtService.verifyAsync<JwtPayload>(token);
      const user: AuthenticatedUser = {
        userId: payload.sub,
        username: payload.username,
      };
      client.data.user = user;
      return user;
    } catch {
      return null;
    }
  }
}
