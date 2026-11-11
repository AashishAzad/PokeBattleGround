// What we embed inside the signed JWT. `sub` ("subject") is the standard
// JWT claim name for "who this token is about" — here, the user's id.
export interface JwtPayload {
  sub: string;
  username: string;
}

// What JwtAuthGuard attaches to the request after verifying a token, so
// controllers can read who is calling without re-parsing the token.
export interface AuthenticatedUser {
  userId: string;
  username: string;
}

// A deliberately minimal request shape — just what the guard and
// controllers need — so we don't depend on Express's types directly.
export interface AuthenticatedRequest {
  headers: { authorization?: string };
  user?: AuthenticatedUser;
}
