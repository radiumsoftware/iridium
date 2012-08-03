# This file defines the Iridium object. It holds configuration
# need for tests. It also defines a new Casper object to use
# for integration tests. It also makes two values available 
# globally through the Iridum object:
#
# 1. The Iridium load path (core files)
# 2. The test support load path (app files)
#
# This files makes it possible to have a local `test_helper.js`
# to define your own functionality and set includes
casper = require('casper')
fs = require('fs')

class Logger
  message: (msg) ->
    console.log(JSON.stringify({iridium: msg}))

class Iridium
  logger: new Logger
  requires: ['iridium/logger']
  scripts: []
  casper: ->
    absolutePaths = []

    for path in @requires.concat(@scripts)
      if path.match(/iridium\//)
        basePath = fs.pathJoin(@root, path)
      else
        basePath = fs.pathJoin(@testRoot, path)

      if fs.exists("#{basePath}.coffee")
        absolutePaths.push "#{basePath}.coffee"
      else if fs.exists("#{basePath}.js")
        absolutePaths.push "#{basePath}.js"
      else
        throw "#{path} is not a valid JS or CS file!"

    options =
      clientScripts: absolutePaths

    _casper = casper.create(options)

    # Hook remote console to local console
    _casper.on 'remote.message', (msg) ->
      console.log msg

    _casper

exports.Iridium = Iridium

exports.create = ->
  new Iridium
