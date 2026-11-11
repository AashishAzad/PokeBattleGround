// Manual test: two authenticated players go through the full Type Clash
// flow (lobby -> type selection -> battle). Run with the backend running:
//   node test-scripts/type-clash-test-client.js
const { registerUser, connectSocket } = require('./helpers');

function connectPlayer(session, label, pickIndex) {
  const socket = connectSocket(session.accessToken);

  socket.on('connect', () => {
    console.log(`[${label}] connected as ${session.user.username}`);
    // Only the difficulty is sent — identity comes from the token.
    socket.emit('typeClash:joinLobby', { difficulty: 'easy' });
  });

  socket.on('typeClash:lobbyUpdate', (d) =>
    console.log(`[${label}] lobbyUpdate:`, d.players.map((p) => p.username)),
  );

  socket.on('typeClash:typeSelectionStarted', (d) => {
    console.log(`[${label}] typeSelectionStarted:`, d.availableTypes);
    const type = d.availableTypes[pickIndex];
    console.log(`[${label}] claiming: ${type}`);
    socket.emit('typeClash:selectType', { difficulty: 'easy', type });
  });

  socket.on('typeClash:typeClaimed', (d) =>
    console.log(`[${label}] typeClaimed:`, d),
  );

  socket.on('typeClash:battleResult', (d) =>
    console.log(
      `[${label}] battleResult — ${d.initialBubbles.length} bubbles, ${d.events.length} events, winner: ${d.winnerType ?? 'none'} (${d.winnerOwnerUsername ?? 'n/a'})`,
    ),
  );

  socket.on('typeClash:error', (d) => console.log(`[${label}] ERROR:`, d.message));
  socket.on('disconnect', (r) => console.log(`[${label}] disconnected (${r})`));
}

async function main() {
  const a = await registerUser('tc_a');
  const b = await registerUser('tc_b');
  connectPlayer(a, 'Player A', 0);
  connectPlayer(b, 'Player B', 1);

  // 20s lobby wait + 15s selection, plus headroom.
  setTimeout(() => {
    console.log('\nTest complete — exiting.');
    process.exit(0);
  }, 45000);
}

main().catch((e) => {
  console.error('Test script failed:', e);
  process.exit(1);
});
