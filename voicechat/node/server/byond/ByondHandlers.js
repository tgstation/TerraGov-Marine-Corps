const { sendJSON } = require('./ByondCommunication');
const { sessionIdToUserCode, userCodeToSocketId, socketIdToUserCode } = require('../state');
const { handleLocationPacket } = require('../proximity');
function handleRequest(data, byondPort, io, shutdown_function) {
    try {
        const { cmd } = data;
        if (!cmd || typeof cmd !== 'string') {
            const errorMsg = "Missing or invalid command";
            console.log(`error: ${errorMsg}`);
            sendJSON({ error: errorMsg, data: data }, byondPort);
            return;
        }

        const commandHandlers = {
            ping: (data) => {
                console.log(data['message']);
                sendJSON({ 'pong': 'Hello from Node', 'time': data["time"] }, byondPort);
            },
            register: (data) => {
                if (data['sessionId'] && data['userCode']) {
                    sessionIdToUserCode.set(data['sessionId'], data['userCode']);
                    console.log(`Registered sessionId: ${data['sessionId']} with userCode: ${data['userCode']}`);
                }
            },
            stop_node: () => shutdown_function(),

            deafen: (data) => {
                if (!data['userCode']) {
                    const errorMsg = "Missing or invalid data: userCode";
                    console.log(`error: ${errorMsg}`);
                    sendJSON({ error: errorMsg, data: data }, byondPort);
                    return;
                }
                const socketId = userCodeToSocketId.get(data['userCode']);
                const socket = io.sockets.sockets.get(socketId)
                if (!socketId || !socket) {
                    const errorMsg = "socket not found";
                    console.log(`error: ${errorMsg}`);
                    sendJSON({ error: errorMsg, data: data }, byondPort);
                    return;
                }
                socket.emit("deafen");
            },
            mute_mic: (data) => {

                if (!data['userCode']) {
                    const errorMsg = "Missing or invalid data: userCode";
                    console.log(`error: ${errorMsg}`);
                    sendJSON({ error: errorMsg, data: data }, byondPort);
                    return;
                }
                const socketId = userCodeToSocketId.get(data['userCode']);
                const socket = io.sockets.sockets.get(socketId)
                if (!socketId || !socket) {
                    const errorMsg = "socket not found";
                    console.log(`error: ${errorMsg}`);
                    sendJSON({ error: errorMsg, data: data }, byondPort);
                    return;
                }
                socket.emit("mute_mic");
            },
            loc: (data) => handleLocationPacket(data, io),

            disconnect: (data) => {
                if (!data['userCode']) {
                    const errorMsg = "Missing or invalid data: userCode";
                    console.log(`error: ${errorMsg}`);
                    sendJSON({ error: errorMsg, data: data }, byondPort);
                    return;
                }
                console.log(`userCode ${data['userCode']} disconnected from byond, cleaning up...`)

                const socketId = userCodeToSocketId.get(data['userCode']);
                const socket = io.sockets.sockets.get(socketId)
                if (!socketId || !socket) {
                    const errorMsg = "socket not found";
                    console.log(`error: ${errorMsg}`);
                    sendJSON({ error: errorMsg, data: data }, byondPort);
                    return;
                }
                socket.emit('update', { type: 'status', data: 'Disconnected: Byond Client changed'});
                socket.disconnect();
                userCodeToSocketId.delete(data['userCode']);
                socketIdToUserCode.delete(socketId);
            },
            mute_userCode: (data) => {
                const userCodeFiring = data['userCodeFiring'];
                const userCodeMuting = data['userCodeMuting'];
                const muting = data['muting']; //true if muting false if unmuting
                if(!userCodeFiring || !userCodeMuting || !muting){
                    const errorMsg = "Missing or invalid data: userCodeFiring or userCodeMuting or muting";
                    console.log(`error: ${errorMsg}`);
                    sendJSON({ error: errorMsg, data: data }, byondPort);
                    return;
                }
                const socketId = userCodeToSocketId.get(userCodeFiring);
                const socket = io.sockets.sockets.get(socketId);
                if (!socketId || !socket) {
                    const errorMsg = "socket not found";
                    console.log(`error: ${errorMsg}`);
                    sendJSON({ error: errorMsg, data: data }, byondPort);
                    return;
                }
                socket.emit('mute_usercode', {userCode: userCodeMutin, mute: muting})
            }
        };

        const handler = commandHandlers[cmd];
        if (handler) {
            handler(data);
        } else {
            const errorMsg = `Unknown command`;
            console.log(`error: ${errorMsg} cmd:${cmd}`);
            sendJSON({ error: errorMsg, cmd: cmd, data: data }, byondPort);
        }
    } catch (error) {
        console.error('Error processing request:', error);
        sendJSON({ error: error.message, data }, byondPort);
    }
}

module.exports = { handleRequest };
