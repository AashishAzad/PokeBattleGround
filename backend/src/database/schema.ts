import {
  index,
  integer,
  pgEnum,
  pgTable,
  timestamp,
  uuid,
  varchar,
} from 'drizzle-orm/pg-core';

// Enum of games — add to this list as we build more games.
export const gameTypeEnum = pgEnum('game_type', [
  'higher_or_lower',
  'type_clash',
  'who_is_that_pokemon',
]);

export const gameModeEnum = pgEnum('game_mode', ['single', 'multi']);

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  username: varchar('username', { length: 32 }).notNull().unique(),
  // scrypt hash in "<salt hex>:<hash hex>" form — see PasswordService.
  // Never selected into an API response (see UsersService.publicUserColumns).
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

// One row per completed game session. This is our source of truth — the
// leaderboard is a derived read (aggregate query) on top of this table.
// Trade-off: for a small user base, aggregating on read is simple and fast
// enough. At larger scale, I'd add a denormalized `user_rankings` table
// updated transactionally on each insert, to avoid re-aggregating on
// every leaderboard read.
export const gameScores = pgTable(
  'game_scores',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    gameType: gameTypeEnum('game_type').notNull(),
    mode: gameModeEnum('mode').notNull(),
    score: integer('score').notNull(),
    createdAt: timestamp('created_at').defaultNow().notNull(),
  },
  (table) => [
    // Composite index: the main leaderboard query filters by game_type and
    // orders by score descending — this index serves that directly instead
    // of a full table scan + sort.
    index('leaderboard_idx').on(table.gameType, table.score),
    index('user_scores_idx').on(table.userId),
  ],
);
