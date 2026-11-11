// Manual test: two authenticated players play a full Who Is That Pokémon
// match. Player A guesses almost immediately, Player B waits ~6s.
//   node test-scripts/who-is-that-pokemon-test-client.js
//
// The server never sends the Pokémon's name over the socket, so the script
// looks it up via the (login-protected) GET /pokemon/:id endpoint to
// simulate a player who recognizes the sprite.
const { registerUser, connectSocket, api } = require('./helpers');

function connectPlayer(session, label, guessDelayMs) {
  const socket = connectSocket(session.accessToken);

  socket.on('connect', () => {
    console.log(`[${label}] connected as ${session.user.username}`);
    // No payload at all — identity comes from the token.
    socket.emit('whoIsThat:joinLobby');
  });

  socket.on('whoIsThat:lobbyUpdate', (d) =>
    console.log(`[${label}] lobbyUpdate:`, d.players.map((p) => p.username)),
  );

  socket.on('whoIsThat:roundStart', async (d) => {
    console.log(`[${label}] round ${d.roundNumber}/${d.totalRounds} — pokemonId ${d.pokemonId}`);
    const { data } = await api('GET', `/pokemon/${d.pokemonId}`, {
      token: session.accessToken,
    });
    setTimeout(() => {
      console.log(`[${label}] guessing "${data.name}"`);
      socket.emit('whoIsThat:guess', { guess: data.name });
    }, guessDelayMs);
  });

  socket.on('whoIsThat:guessResult', (d) => console.log(`[${label}] guessResult:`, d));
  socket.on('whoIsThat:roundEnd', (d) => console.log(`[${label}] roundEnd — "${d.pokemonName}"`));
  socket.on('whoIsThat:matchEnd', (d) => console.log(`[${label}] matchEnd:`, d.finalScores));
  socket.on('whoIsThat:error', (d) => console.log(`[${label}] ERROR:`, d.message));
}

async function main() {
  const a = await registerUser('witp_a');
  const b = await registerUser('witp_b');
  connectPlayer(a, 'Player A', 500);
  connectPlayer(b, 'Player B', 6000);

  // 20s lobby + 5 rounds x (10s + 2.5s) is about 82s — leave headroom.
  setTimeout(() => {
    console.log('\nTest complete — exiting.');
    process.exit(0);
  }, 100000);
}

main().catch((e) => {
  console.error('Test script failed:', e);
  process.exit(1);
});
