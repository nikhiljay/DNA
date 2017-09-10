var path = require('path');
var Tesseract = require('tesseract.js')
var ncbi = require('bionode-ncbi')
var seq = require('bionode-seq')
var ngrok = require('ngrok')
var express = require('express');
var bodyParser = require('body-parser');
var app = express();

// var image = path.resolve(__dirname, 'text.png');
var inputStrand = ""
var method = ""

app.use(bodyParser.json())

app.post('/', function (request, response) {
    response.send(request.body);

    var data = request.body //get data from app
    inputStrand = data['strand']
    method = data['method']
    console.log("-------------")
    console.log("input strand: " + inputStrand)
    console.log("method: " + method)
});

app.get('/', function (request, response) {

    // ncbi.search('taxonomy', 'solenopsis invicta').on('data', function(data) {
    //   var output = data
    //   response.send(output);
    // })

    // Tesseract.recognize(image)
    //   .then(function(result) {
    //     var complement = {"strand": seq.complement(result.text)}
    //     response.send(complement)
    //   })

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
    response.send(outputStrand) //send data to app
});

app.listen(8000);
