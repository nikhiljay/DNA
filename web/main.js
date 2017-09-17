var path = require('path');
var Tesseract = require('tesseract.js')
var ncbi = require('bionode-ncbi')
var seq = require('bionode-seq')
var ngrok = require('ngrok')
var bodyParser = require('body-parser');
var app = require('express')();

// var image = path.resolve(__dirname, 'text.png');
var inputStrand = ""
var method = ""

app.use(bodyParser.json())

app.post('/data', function(req, res) {
    res.send(req.body);

    var data = req.body //get data from app
    inputStrand = data['strand']
    method = data['method']
    console.log("-------------")
    console.log("input strand: " + inputStrand)
    console.log("method: " + method)
});

app.get('/', function(req, res) {
  res.sendFile(__dirname + '/index.html');
})

app.get('/data', function(req, res) {
    var outputStrand = {"strand": seq.complement(inputStrand)}

    switch(method) {
      case "Reverse":
          outputStrand = {"strand": seq.reverse(inputStrand)}
          break;
      case "Complement":
          outputStrand = {"strand": seq.complement(inputStrand)}
          break;
      case "Transcribe":
          outputStrand = {"strand": seq.transcribe(inputStrand)}
          break;
      case "Translate":
          outputStrand = {"strand": seq.translate(inputStrand)}
          break;
    }

    console.log("output strand: " + outputStrand['strand'])
    res.send(outputStrand) //send data to app
});

app.listen(8000);
