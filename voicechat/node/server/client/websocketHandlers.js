const { sessionIdToUserCode, userCodeToSocketId, socketIdToUserCode} = require('../state');
const { sendJSON } = require('../byond/ByondCommunication');
const { createCredential, revokeCredential} = require('../turn')
function createConnectionHandler(byondPort, io) {
    return function handleConnection(socket) {
        console.log('A user connected:', socket.id);

        const authTimer = setTimeout(() => {
            if (!socketIdToUserCode.get(socket.id)) {
                console.log(`Unauthenticated socket ${socket.id} timed out, disconnecting`);
                socket.emit('update', { type: 'update', data: 'Disconnected: Authentication timeout' });
                socket.disconnect()
            }
        }, 5000);
        socket.on('join', (data) => {
            const sessionId = data.sessionId;
            const userCode = sessionIdToUserCode.get(sessionId);
            if (userCode) {
                // Clear the timer on successful auth
                clearTimeout(authTimer);
                // create turn crediential
                createCredential(sessionId);
                // Avoid re-associating if already set (edge case for multiple 'join' emits)
                if (!socket.userCode) {
                    userCodeToSocketId.set(userCode, socket.id);
                    socketIdToUserCode.set(socket.id, userCode);
                    sessionIdToUserCode.delete(sessionId);
                    socket.userCode = userCode;
                    console.log(`Associated userCode ${userCode} with socket ${socket.id}`);
                    socket.emit('update', { type: 'status', data: 'Connected successfully' });
                    // sendJSON({ 'registered': userCode }, byondPort);
                }
            } else {
                console.log('Invalid sessionId', sessionId);
                socket.emit('update', { type: 'status', data: 'Disconnected: bad sessionId. make sure you use the verb to connect as you need a new link each time.' });
                socket.disconnect();
                revokeCredential(sessionId);
            }
        });    
        socket.on('mic_access_granted', () => {
            const userCode = socketIdToUserCode.get(socket.id);
            if(userCode) sendJSON({ 'confirmed': userCode }, byondPort);
        })    
        socket.on('disconnect_page', () => {
            const userCode = socketIdToUserCode.get(socket.id);
            if (userCode) {
                sendJSON({disconnect: userCode}, byondPort);
                userCodeToSocketId.delete(userCode);
                socketIdToUserCode.delete(socket.id)
                console.log(`Removed userCode ${userCode} on disconnect`);
            }
            socket.emit('update', { type: 'status', data: 'Disconnecting...'});
            socket.disconnect();
            console.log('User disconnected:', socket.id);
            revokeCredential(sessionId);
        });

        socket.on('offer', (data) => {
            const { to, offer } = data;
            const targetSocketId = userCodeToSocketId.get(to);
            const socket_sending = io.sockets.sockets.get(targetSocketId)
            if (targetSocketId && socket_sending) {
                socket_sending.emit('offer', { from: socket.userCode, offer });
            }
        });

        socket.on('answer', (data) => {
            const { to, answer } = data;
            const targetSocketId = userCodeToSocketId.get(to);
            const socket_sending = io.sockets.sockets.get(targetSocketId)
            if (targetSocketId && socket_sending) {
                socket_sending.emit('answer', { from: socket.userCode, answer });
            }
        });

        socket.on('ice-candidate', (data) => {
            const { to, candidate } = data;
            const targetSocketId = userCodeToSocketId.get(to);
            const socket_sending = io.sockets.sockets.get(targetSocketId)
            if (targetSocketId && socket_sending) {
                socket_sending.emit('ice-candidate', { from: socket.userCode, candidate });
            }
        });
        socket.on('ice_failed', (event) => {
            const userCode = socketIdToUserCode.get(socket.id);
            console.log(event)
            if(userCode) sendJSON({ 'ice_failed': userCode}, byondPort);
        }),
        socket.on('voice_activity', (data) => {
            const userCode = socketIdToUserCode.get(socket.id); //ack
            sendJSON({voice_activity: userCode, active: data['active']}, byondPort)
        });
    };
}

module.exports = { createConnectionHandler };