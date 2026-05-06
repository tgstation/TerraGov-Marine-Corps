const Turn = require('node-turn');


const server = new Turn({
  authMech: 'long-term',
  realm: '127.0.0.1',
  listeningPort: 3478,
});

function startTurnServer(){
  server.start();
  return server
}

function createCredential(sessionId) {
  server.addUser(sessionId, sessionId);
}

// Function to remove credential (call this when session ends or after use)
function revokeCredential(sessionId) {
  server.removeUser(sessionId);
}

module.exports = {startTurnServer, createCredential, revokeCredential};