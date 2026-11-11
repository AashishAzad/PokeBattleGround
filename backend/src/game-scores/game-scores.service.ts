import { Inject, Injectable } from '@nestjs/common';
import { desc, eq, sql } from 'drizzle-orm';
import { DRIZZLE } from '../database/database.module';
import type { DrizzleDB } from '../database/database.module';
import { gameScores, users } from '../database/schema';
import { SubmitScoreDto } from './dto/submit-score.dto';

// Any game module injects THIS service to persist scores, instead of
// touching `gameScores`/Drizzle directly. That keeps scoring/ranking logic
// in one place instead of duplicated per game.
@Injectable()
export class GameScoresService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDB) {}

  async submitScore(dto: SubmitScoreDto) {
    const [score] = await this.db
      .insert(gameScores)
      .values({
        userId: dto.userId,
        gameType: dto.gameType,
        mode: dto.mode,
        score: dto.score,
      })
      .returning();

    return score;
  }

  // Leaderboard for one specific game. Joins `users` so the response
  // includes `username` directly — without the join, the client would only
  // get a raw userId with nothing readable to display. Uses the composite
  // index on (gameType, score) from schema.ts.
  async getLeaderboardForGame(gameType: string, limit = 20) {
    return this.db
      .select({
        id: gameScores.id,
        userId: gameScores.userId,
        username: users.username,
        gameType: gameScores.gameType,
        mode: gameScores.mode,
        score: gameScores.score,
        createdAt: gameScores.createdAt,
      })
      .from(gameScores)
      .innerJoin(users, eq(users.id, gameScores.userId))
      .where(eq(gameScores.gameType, gameType as any))
      .orderBy(desc(gameScores.score))
      .limit(limit);
  }

  // Global ranking across all games, weighted so multiplayer scores count
  // more than single-player — matching the product requirement that
  // multiplayer gets higher priority.
  //
  // Trade-off worth knowing: this aggregates on every read. Fine at a small
  // scale; for thousands of users I'd maintain a denormalized
  // `user_rankings` table updated transactionally on each score insert.
  async getGlobalRanking(limit = 50) {
    const MULTIPLAYER_WEIGHT = 2;
    const SINGLEPLAYER_WEIGHT = 1;

    // The ::int casts matter: without them Postgres receives the bound
    // parameters untyped and fails with "operator does not exist:
    // integer * text".
    return this.db.execute(sql`
      SELECT
        u.id AS "userId",
        u.username,
        SUM(
          gs.score * CASE
            WHEN gs.mode = 'multi' THEN ${MULTIPLAYER_WEIGHT}::int
            ELSE ${SINGLEPLAYER_WEIGHT}::int
          END
        ) AS "weightedScore"
      FROM game_scores gs
      JOIN users u ON u.id = gs.user_id
      GROUP BY u.id, u.username
      ORDER BY "weightedScore" DESC
      LIMIT ${limit}
    `);
  }
}
