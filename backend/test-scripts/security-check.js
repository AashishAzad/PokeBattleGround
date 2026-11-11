// Verifies the security lockdown. Prints PASS/FAIL per check and exits
// non-zero if anything fails:
//   node test-scripts/security-check.js
const { registerUser, connectSocket, api, BASE_URL } = require('./helpers');

let failures = 0;
function check(name, ok, detail = '') {
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${ok ? '' : `  -> ${detail}`}`);
  if (!ok) failures++;
}

async function main() {
  const a = await registerUser('sec_a');
  const b = await registerUser('sec_b');

  // --- Routes that must require a login ---
  let r = await api('GET', '/game-scores/global-ranking');
  check('global-ranking without token is 401', r.status === 401, r.status);
  r = await api('GET', '/game-scores/global-ranking', { token: a.accessToken });
  check('global-ranking with token is 200', r.status === 200, r.status);
  r = await api('GET', '/pokemon/25');
  check('GET /pokemon/25 without token is 401', r.status === 401, r.status);
  r = await api('POST', '/higher-or-lower/start');
  check('higher-or-lower/start without token is 401', r.status === 401, r.status);

  // --- Routes that must not exist ---
  r = await api('POST', '/game-scores', {
    token: a.accessToken,
    body: { userId: a.user.id, gameType: 'higher_or_lower', mode: 'single', score: 999999 },
  });
  check('POST /game-scores (fake score submit) is gone (404)', r.status === 404, r.status);
  r = await api('POST', '/users', { token: a.accessToken, body: { username: 'ghost_user' } });
  check('POST /users (anonymous signup) is gone (404)', r.status === 404, r.status);
  r = await api('GET', '/users', { token: a.accessToken });
  check('GET /users (list everyone) is gone (404)', r.status === 404, r.status);

  // --- Input validation ---
  r = await api('GET', '/game-scores/leaderboard/not_a_game', { token: a.accessToken });
  check('unknown game type is 400', r.status === 400, r.status);
  r = await api('POST', '/type-clash/single-player/start', {
    token: a.accessToken,
    body: { difficulty: 'easy', chosenType: 'banana' },
  });
  check('single-player with invented type is 400', r.status === 400, r.status);
  r = await api('POST', '/type-clash/single-player/start', {
    token: a.accessToken,
    body: { userId: b.user.id, difficulty: 'easy', chosenType: 'fire' },
  });
  check('single-player rejects a client-supplied userId (400)', r.status === 400, r.status);

  // --- Session ownership ---
  const start = await api('POST', '/higher-or-lower/start', { token: a.accessToken });
  check('A can start a Higher or Lower game', start.status === 201, start.status);
  const sessionId = start.data?.sessionId;
  r = await api('POST', '/higher-or-lower/guess', {
    token: b.accessToken,
    body: { sessionId, guess: 'higher' },
  });
  check("B cannot play A's session (404)", r.status === 404, r.status);
  r = await api('POST', '/higher-or-lower/guess', {
    token: a.accessToken,
    body: { sessionId, guess: 'higher' },
  });
  check('A can play their own session', r.status === 201, r.status);

  // --- Sockets ---
  // NOTE: calling socket.close() ourselves fires the 'disconnect' listener
  // synchronously, so we detach it first — otherwise our own cleanup would
  // be mistaken for the server's behaviour and could resolve the promise
  // with the wrong answer.
  const rejected = await new Promise((resolve) => {
    const s = connectSocket(undefined); // no token
    const t = setTimeout(() => {
      s.removeAllListeners('disconnect');
      s.close();
      resolve(false); // the server never kicked us out
    }, 3000);
    s.on('disconnect', (reason) => {
      clearTimeout(t);
      // 'io server disconnect' = the SERVER ended the connection.
      resolve(reason === 'io server disconnect');
    });
  });
  check('socket without a token is disconnected by the server', rejected);

  const accepted = await new Promise((resolve) => {
    const s = connectSocket(a.accessToken);
    let connected = false;
    s.on('connect', () => { connected = true; });
    const t = setTimeout(() => {
      s.removeAllListeners('disconnect');
      s.close();
      // Must have genuinely connected AND not been kicked out meanwhile.
      resolve(connected);
    }, 2000);
    s.on('disconnect', () => { clearTimeout(t); resolve(false); });
  });
  check('socket with a valid token connects and stays connected', accepted);

  console.log(failures === 0 ? '\nAll checks passed.' : `\n${failures} check(s) FAILED.`);
  process.exit(failures === 0 ? 0 : 1);
}

main().catch((e) => {
  console.error(`Could not reach ${BASE_URL}:`, e);
  process.exit(1);
});