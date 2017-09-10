#!/usr/bin/env node
var tool = require('./')
var through = require('through2')
var split = require('split')
var minimist = require('minimist')

var argv = minimist(process.argv.slice(2))
var method = argv._[0]
var params = argv._.slice(1)

var operation = tool[method].apply(this, params)

process.stdin.setEncoding('utf8');

if (!process.stdin.isTTY) {
  process.stdin
  .pipe(split())
  .pipe(JSONparse())
  .pipe(operation)
  .on('data', function(data) {
    if (typeof data === 'object') {
      data = JSON.stringify(data)
    }
    console.log(data)
  })
  .on('error', console.log)
}

function JSONparse() {
  var stream = through.obj(transform)
  return stream
  function transform(obj, enc, next) {
    try { obj = JSON.parse(obj) }
    catch(e) {}
    if (obj !== '') { this.push(obj) }
    next()
  }
}
