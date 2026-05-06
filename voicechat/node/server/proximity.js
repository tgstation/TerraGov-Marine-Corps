const { userCodeToSocketId } = require('./state');

const prevPackets = new Map();

function normalizeStringify(obj) {
    if ('none' in obj) {
        return JSON.stringify({ none: 1 });
    }
    const sortedPeers = Object.fromEntries(
        Object.entries(obj.peers).sort((a, b) => a[0].localeCompare(b[0]))
    );
    return JSON.stringify({ peers: sortedPeers, own: obj.own });
}

const handleLocationPacket = (packet, io) => {
    for (const room in packet) {
        if (room === "loc") continue;
        const isNoProx = room.endsWith('_noprox');
        const locations = packet[room];
        const userCodes = Object.keys(locations);
        const numUsers = userCodes.length;

        // Initialize peers for all users
        const peersByUser = {};
        for (const userCode of userCodes) {
            peersByUser[userCode] = {};
        }

        if (isNoProx) { // connect everyone with distance 0
            for (let i = 0; i < numUsers; i++) {
                const userCode = userCodes[i];
                for (let j = 0; j < numUsers; j++) {
                    if (i !== j) {
                        const otherCode = userCodes[j];
                        peersByUser[userCode][otherCode] = 0;
                    }
                }
            }
        } else {
            for (let i = 0; i < numUsers; i++) {
                const userCode = userCodes[i];
                const [ux, uy] = locations[userCode];
                for (let j = i + 1; j < numUsers; j++) {
                    const otherCode = userCodes[j];
                    const [ox, oy] = locations[otherCode];
                    const dx = Math.abs(ux - ox);
                    const dy = Math.abs(uy - oy);
                    if (dx < 8 && dy < 8) {
                        const dist = Math.hypot(ux - ox, uy - oy);
                        const roundedDist = Math.round(dist * 10) / 10;
                        peersByUser[userCode][otherCode] = roundedDist;
                        peersByUser[otherCode][userCode] = roundedDist;
                    }
                }
            }
        }

        // if changed emit
        for (const userCode of userCodes) {
            const peers = peersByUser[userCode];
            const socketId = userCodeToSocketId.get(userCode);
            const socket = io.sockets.sockets.get(socketId);
            if (socketId && socket) {
                const out_packet = Object.keys(peers).length === 0
                    ? { none: 1 }
                    : { peers: peers, own: userCode };
                const newStr = normalizeStringify(out_packet);
                const prevStr = prevPackets.get(userCode);
                if (newStr !== prevStr) {
                    socket.emit('loc', out_packet);
                    prevPackets.set(userCode, newStr);
                }
            } else {
                // console.log(`No socket found for userCode: ${userCode}`);
            }
        }
    }
};
module.exports = {handleLocationPacket};
