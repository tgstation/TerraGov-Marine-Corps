const fs = require('fs');
const net = require('net');
const path = require('path');

const { sendJSON } = require('./ByondCommunication');
const { handleRequest } = require('./ByondHandlers');

const PIPE_NAME = 'byond_node.sock';
const PIPE_PATH = path.resolve(process.cwd(), PIPE_NAME)

function cleanUpExistingSocket(PIPE_PATH){
    if(fs.existsSync(PIPE_PATH)){
        console.log(`found existing named socket at ${PIPE_NAME} removing...`)
        fs.unlinkSync(PIPE_PATH);
    }
}

function startByondServer(byondPort, io, shutdown_function) {
    const ByondServer = net.createServer((stream) => {
        stream.on('data', (data) => {
            const jsonStr = data.toString('utf-8');
            try {
                const json = JSON.parse(jsonStr);
                // console.log('Received JSON:', json);
                handleRequest(json, byondPort, io, shutdown_function);
            } catch (err) {
                console.log(jsonStr);
                console.error('Invalid JSON:', err);
                sendJSON({ error: 'invalid JSON', data: err }, byondPort)
            }
        });
        stream.on('end', () => {
        });
    });
    cleanUpExistingSocket(PIPE_PATH)
    ByondServer.listen(PIPE_PATH, () => {
        console.log(`socket server listening on ${PIPE_NAME}`);
    });

    ByondServer.on('error', (err) => {
        console.error('Pipe server error:', err);
    });
    return ByondServer;
}


module.exports = { startByondServer };