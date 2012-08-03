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

class Iridium
  includes: []
  message: (msg) ->
    console.log "<iridium>#{JSON.stringify(msg)}</iridium>"

  casper: ->
    absolutePaths = []

    for include in @includes
      if include.match(/iridium\//)
        basePath = fs.pathJoin(@root, include)
      else
        basePath = fs.pathJoin(@testRoot, include)

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
