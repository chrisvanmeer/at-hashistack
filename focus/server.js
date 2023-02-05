const http = require('http');

const server = http.createServer((req, res) => {
  res.end('Stay Focused!');
  console.log('focus route called');
});

server.listen(8080);
