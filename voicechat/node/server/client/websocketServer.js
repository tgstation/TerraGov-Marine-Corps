const http = require('http');
const { Server } = require('socket.io');
const { createConnectionHandler } = require('./websocketHandlers');


function startWebSocketServer(byondPort, nodePort) {
    const httpserver = http.createServer();
    httpserver.listen(nodePort, "0.0.0.0")
    const io = new Server(httpserver, {
        cors: {
            origin: true
        }
    });
    const handleConnection = createConnectionHandler(byondPort, io);
    io.on('connection', handleConnection);
    return { io, httpserver };
}

function disconnectAllClients(io) {
    io.emit('server-shutdown');
    setTimeout(() => {
        io.sockets.sockets.forEach((socket) => {
            socket.emit('update', { type: 'update', data: 'Disconnected: Disconnecting all clients' });
            socket.disconnect(true);
            revokeCredential(sessionId);
        });
    }, 2000);
}
module.exports = { startWebSocketServer, disconnectAllClients };