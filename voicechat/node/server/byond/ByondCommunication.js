const net = require('net');


function formatData(data) {
    return data.startsWith('?') ? data : `?${data}`;
}

function buildPacket(data) {
    const formattedData = formatData(data);
    const dataLength = formattedData.length;
    const remainingSize = dataLength + 6; // Length field value: type (1) + padding (4) + data + null (1)

    if (remainingSize > 65535) {
        throw new Error(`Data exceeds maximum size: ${remainingSize}`);
    }

    const header = Buffer.alloc(9);
    header[1] = 0x83;
    header.writeUInt16BE(remainingSize, 2);

    const queryBuffer = Buffer.from(formattedData, 'utf8');
    const nullBuffer = Buffer.alloc(1); // 0x00

    return Buffer.concat([header, queryBuffer, nullBuffer]);
}

function sendByondTopic(host, port, data, timeout = 5000) {
    return new Promise((resolve, reject) => {
        if (typeof data !== 'string') {
            reject(new Error('Data must be a string'));
            return;
        }

        let packet;
        try {
            packet = buildPacket(data);
        } catch (err) {
            reject(err);
            return;
        }

        const client = new net.Socket();
        client.setTimeout(timeout, () => {
            client.destroy();
            reject(new Error('Connection timeout'));
        });

        client.on('error', (err) => {
            client.destroy();
            reject(err);
        });

        client.connect(port, host, () => {
            client.write(packet, () => {
                client.end(); 
                resolve();
            });
        });
    });
}

async function sendJSON(data, byondPort) {
    const out = JSON.stringify(data);
    try {
        await sendByondTopic('127.0.0.1', byondPort, out);
    } catch (err) {
        console.error('Failed to send command:', err.message);
    }
}

module.exports = { sendJSON };