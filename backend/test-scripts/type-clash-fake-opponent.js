// Simulates ONE opponent so you can test the real Flutter app on a device
// against a second participant. Run with:
//   node test-scripts/type-clash-fake-opponent.js [difficulty]
// then join the SAME difficulty in the app within a few seconds.
const { registerUser, connectSocket } = require('./helpers');

const DIFFICULTY = process.argv[2] || 'easy';

async function main() {
  const session = await registerUser('fake_opp');
  console.log(`Fake opponent: ${session.user.username}`);

  const socket = connectSocket(session.accessToken);

  socket.on('connect', () => {
    socket.emit('typeClash:joinLobby', { difficulty: DIFFICULTY });
    console.log(`Joined "${DIFFICULTY}" lobby — now join the same one in the app.`);
  });

  socket.on('typeClash:lobbyUpdate', (d) =>
    console.log('Lobby players:', d.players.map((p) => p.username)),
  );

  socket.on('typeClash:typeSelectionStarted', (d) => {
    console.log('Type selection started:', d.availableTypes);
    // Think for a couple seconds, then claim a random offered type.
    setTimeout(() => {
      const type = d.availableTypes[Math.floor(Math.random() * d.availableTypes.length)];
      console.log(`Claiming: ${type}`);
      socket.emit('typeClash:selectType', { difficulty: DIFFICULTY, type });
    }, 2000);
  });

  socket.on('typeClash:typeClaimed', (d) => console.log('Type claimed:', d));
  socket.on('typeClash:battleResult', (d) =>
    console.log(`Battle result — winner: ${d.winnerType ?? 'none'} (${d.winnerOwnerUsername ?? 'n/a'})`),
  );
  socket.on('typeClash:error', (d) => console.log('ERROR:', d.message));
  socket.on('disconnect', (r) => console.log(`Disconnected (${r})`));
}

main().catch((e) => {
  console.error('Script failed:', e);
  process.exit(1);
});
