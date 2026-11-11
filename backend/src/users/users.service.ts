import {
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DRIZZLE } from '../database/database.module';
import type { DrizzleDB } from '../database/database.module';
import { users } from '../database/schema';

// The ONLY columns that may ever leave this service in an API response.
// Every query below selects/returns exactly these — never `select()` with
// no column list, which would leak `passwordHash`.
const publicUserColumns = {
  id: users.id,
  username: users.username,
  createdAt: users.createdAt,
};

// All database access for the "users" domain lives here. There is no
// UsersController: users are created only through AuthService (register)
// and read only through /auth/me — so there is no public endpoint that can
// create accounts directly or list everyone.
@Injectable()
export class UsersService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  async createWithPassword(username: string, passwordHash: string) {
    const existing = await this.findByUsername(username);
    if (existing) {
      throw new ConflictException(`Username "${username}" is already taken`);
    }

    const [user] = await this.db
      .insert(users)
      .values({ username, passwordHash })
      .returning(publicUserColumns);

    return user;
  }

  async findOne(id: string) {
    const [user] = await this.db
      .select(publicUserColumns)
      .from(users)
      .where(eq(users.id, id));

    if (!user) {
      throw new NotFoundException(`User with id "${id}" not found`);
    }

    return user;
  }

  async findByUsername(username: string) {
    const [user] = await this.db
      .select(publicUserColumns)
      .from(users)
      .where(eq(users.username, username));

    return user ?? null;
  }

  // The one place the password hash is intentionally read — used only by
  // AuthService.login, and its result must never be returned from a controller.
  async findAuthRecordByUsername(username: string) {
    const [record] = await this.db
      .select({
        id: users.id,
        username: users.username,
        passwordHash: users.passwordHash,
      })
      .from(users)
      .where(eq(users.username, username));

    return record ?? null;
  }
}
