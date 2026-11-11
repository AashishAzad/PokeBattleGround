// Shared helpers for the manual test scripts. Users are created via the
// real signup endpoint, and sockets authenticate with the returned token —
// exactly like the Flutter app does.
const { io } = require('socket.io-client');

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

// Registers a fresh throwaway user. Usernames must be 3-32 chars of
// letters/numbers/underscores, so we build one from a prefix + random suffix.
async function registerUser(prefix) {
  const suffix = Math.random().toString(36).slice(2, 8);
  const username = `${prefix}_${suffix}`;
  const res = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password: 'TestPassw0rd!' }),
  });
  if (!res.ok) {
    throw new Error(`register failed (${res.status}): ${await res.text()}`);
  }
  return res.json(); // { accessToken, user: { id, username } }
}

// Opens a socket that presents the token in the handshake.
function connectSocket(accessToken) {
  return io(BASE_URL, {
    transports: ['websocket'],
    auth: { token: accessToken },
  });
}

// Plain fetch wrapper that attaches the bearer token and returns the status
// along with parsed JSON (or null).
async function api(method, path, { token, body } = {}) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  let data = null;
  try {
    data = await res.json();
  } catch {
    // empty or non-JSON body
  }
  return { status: res.status, data };
}

module.exports = { BASE_URL, registerUser, connectSocket, api };
