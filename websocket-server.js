const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

console.log('GustoPOS WebSocket Server running on ws://localhost:8080');

wss.on('connection', function connection(ws) {
    console.log('Client connected');

    ws.on('message', function incoming(message) {
        console.log('Received: %s', message);

        // Broadcast to all clients
        wss.clients.forEach(function each(client) {
            if (client.readyState === WebSocket.OPEN) {
                client.send(message.toString());
            }
        });
    });

    ws.on('close', () => console.log('Client disconnected'));
});
