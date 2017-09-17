var path = require('path');
var Tesseract = require('tesseract.js')
var ncbi = require('bionode-ncbi')
var seq = require('bionode-seq')
var ngrok = require('ngrok')
var bodyParser = require('body-parser');
var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);

var inputStrand = ""
var method = ""

//DATA
app.use(bodyParser.json())

io.on('connection', function(socket) {
  app.post('/data', function(req, res) {
    res.send(req.body);

    var data = req.body //get data from app
    inputStrand = data['strand']
    method = data['method']
    io.emit('webStrand', {
      'inputStrand': inputStrand
    });
    console.log("-------------")
    console.log("input strand: " + inputStrand)
    console.log("method: " + method)
  });

  app.get('/data', function(req, res) {
    var outputStrand = {
      "outputStrand": seq.complement(inputStrand)
    }

    switch (method) {
      case "Reverse":
        outputStrand = {
          "outputStrand": seq.reverse(inputStrand)
        }
        break;
      case "Complement":
        outputStrand = {
          "outputStrand": seq.complement(inputStrand)
        }
        break;
      case "Transcribe":
        outputStrand = {
          "outputStrand": seq.transcribe(inputStrand)
        }
        break;
      case "Translate":
        outputStrand = {
          "outputStrand": seq.translate(inputStrand)
        }
        break;
    }

    console.log("output strand: " + outputStrand['outputStrand'])
    res.send(outputStrand) //send data to app
    io.emit('webStrand', outputStrand);
  });
});

//WEB
app.get('/', function(req, res) {
  res.sendFile(__dirname + '/index.html');
})

// app.listen(8000);
server.listen(8000, function() {
  console.log('listening on *:8000');
});
