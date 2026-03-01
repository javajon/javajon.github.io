const PORT = process.env.PORT || 3000;

var express = require('express');

var app = express();

app.get('/', function (req, res) {
  res.send('Hello World!\n');
});

app.listen(PORT, function () {
  console.log('Listening on port ${PORT}!');
  console.log('http://localhost:${PORT}');
});
