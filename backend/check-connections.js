// Run from the backend folder:  node check-connections.js
// Tests the Postgres and Redis connection strings in .env and explains
// failures. It NEVER prints passwords — only hosts and ports.
const fs = require('fs');

require('dotenv').config({ quiet: true });

// Some packages expose their main export as `.default` when loaded with
// require(), so accept either shape.
const postgresModule = require('postgres');
const postgres = postgresModule.default ?? postgresModule;
const redisModule = require('ioredis');
const Redis = redisModule.default ?? redisModule;

function checkVar(label, value) {
  if (!value) {
    console.log(`${label}: NOT SET  <-- .env wasn't loaded, or this variable is missing`);
    return false;
  }
  if (/[\[\]*<>]/.test(value)) {
    console.log(`${label}: set, but it still contains [ ] * < or > — a placeholder or masked value was pasted instead of the real one`);
    return false;
  }
  try {
    const u = new URL(value);
    console.log(`${label}: set, host=${u.hostname}, port=${u.port || '(default)'}`);
    return true;
  } catch {
    console.log(`${label}: set but NOT a valid URL — URL-encode special characters in the password (@ becomes %40)`);
    return false;
  }
}

function explain(e) {
  const parts = [e.message, e.code, e.name].filter(Boolean);
  if (Array.isArray(e.errors)) {
    parts.push(...e.errors.map((x) => x.code || x.message));
  }
  return parts.join(' | ') || String(e);
}

async function main() {
  console.log('Folder:', process.cwd());
  console.log('.env exists here:', fs.existsSync('.env'));
  console.log('.env.txt exists here (Windows hid the extension?):', fs.existsSync('.env.txt'));
  console.log('');

  const dbOk = checkVar('DATABASE_URL', process.env.DATABASE_URL);
  const redisOk = checkVar('REDIS_URL', process.env.REDIS_URL);
  console.log('');

  if (dbOk) {
    const sql = postgres(process.env.DATABASE_URL, { max: 1 });
    try {
      const [row] = await sql`select now() as now`;
      console.log('Postgres OK:', row.now);
    } catch (e) {
      console.error('Postgres FAILED:', explain(e));
    } finally {
      await sql.end();
    }
  } else {
    console.log('Postgres: skipped (fix DATABASE_URL first)');
  }

  if (redisOk) {
    const redis = new Redis(process.env.REDIS_URL, {
      maxRetriesPerRequest: 1,
      lazyConnect: true,
    });
    redis.on('error', () => {});
    try {
      await redis.connect();
      console.log('Redis OK:', await redis.ping());
    } catch (e) {
      console.error('Redis FAILED:', explain(e));
    } finally {
      redis.disconnect();
    }
  } else {
    console.log('Redis: skipped (fix REDIS_URL first)');
  }
}

main();
