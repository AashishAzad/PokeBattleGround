import { Global, Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { drizzle, PostgresJsDatabase } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

export const DRIZZLE = Symbol('DRIZZLE_CONNECTION');

// Exported so any service can type its injected DB client correctly
// (e.g. `@Inject(DRIZZLE) private readonly db: DrizzleDB`) instead of
// falling back to `any`.
export type DrizzleDB = PostgresJsDatabase<typeof schema>;

// @Global() means every other module can inject DRIZZLE without importing
// DatabaseModule directly.
@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: DRIZZLE,
      inject: [ConfigService],
      useFactory: (config: ConfigService): DrizzleDB => {
        const connectionString = config.getOrThrow<string>('DATABASE_URL');
        // `max: 10` caps pooled connections — fine for our scale, and
        // respects Supabase's connection limits on the free tier pooler.
        const client = postgres(connectionString, { max: 10 });
        return drizzle(client, { schema });
      },
    },
  ],
  exports: [DRIZZLE],
})
export class DatabaseModule {}
