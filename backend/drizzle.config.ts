import { defineConfig } from 'drizzle-kit';
import * as dotenv from 'dotenv';

// quiet: true silences dotenv's promotional "tip" log line.
dotenv.config({ quiet: true });

export default defineConfig({
  // Where our table definitions live
  schema: './src/database/schema.ts',
  // Where generated SQL migration files will be written
  out: './drizzle/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  // Keeps migration history readable during development
  verbose: true,
  strict: true,
});
