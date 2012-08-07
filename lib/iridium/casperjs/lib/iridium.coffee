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

fs = require('fs')
colorizer = require('colorizer')
logger = requireExternal('iridium/logger').create()

class IridiumCasper extends require('casper').Casper
  formatBacktrace: (trace) ->
    formatted = []

    for e in trace 
      if e.file
        line = "#{e.file}:#{e.line}"
      else
        line = "(casperjs)"

      if e.function
        line = "#{line} in #{e['function']}" 

      formatted.push line

    formatted

  constructor: (options) ->
    super options

    @logger = logger

    # Hook remote console to this one
    @on 'remote.message', (msg) ->
      console.log msg

    # Disable colorizing
    cls = 'Dummy'
    @options.colorizerType = cls
    @colorizer = colorizer.create(cls)

    # Redfine the runTest method to emit an event we can list to
    @test.runTest = (testFile) ->
      @emit("test.started", testFile)
      @running = true; # this.running is set back to false with done()
      @exec(testFile)

    # Patch the test.done method to emit the done event
    # so we can print test results in real time.
    # This functionality should make it into the 1.0 release.
    #
    # It was added in this commit: 
    # https://github.com/n1k0/casperjs/commit/4eee81406c1e672eec58ca8c80e336ab2863e988
    @test.done = ->
      @emit('test.done')
      @running = false

    currentTest = {}
    startTime = null

    # Record that a new test and started and wipe state
    @test.on 'test.started', (testFile) ->
      startTime = (new Date()).getTime()
      currentTest = {}
      currentTest.assertions = 0
      currentTest.name = testFile

    # This doesn't mean that the entire test passed, but simply one
    # single assertion was correct
    @test.on 'success', ->
      currentTest.assertions++

    # remove the stock functionality so we can replace with ours
    @removeAllListeners(['error'])

    #The test raised an exception
    @on 'error', (error, trace) ->
      currentTest.error = true
      currentTest.backtrace = @formatBacktrace(trace)
      currentTest.message = error
      @test.done()

    @test.on 'fail', (failure) -> 
      if failure.type == 'uncaughtError'
        currentTest.error = true
        currentTest.message = failure.message
        currentTest.backtrace = ["#{failure.file}:#{failure.line}"]
      else
        currentTest.assertions++
        currentTest.failed = true
        currentTest.message = failure.type + ": " + (failure.message || failure.standard || "(no message was entered)")
        currentTest.backtrace = [failure.file]
        @done()

    @test.on 'test.done', =>
      currentTest.time = (new Date().getTime()) - startTime
      @logger.message currentTest

    @test.on 'tests.complete', =>
      console.log("Tests complete!")
      @exit()

class Iridium
  requires: ['iridium/logger']
  scripts: []
  casper: (options) ->
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
        console.abort "#{path} is not a valid JS or CS file!"
        phantom.exit 0

    options ||= {}
    options.clientScripts = absolutePaths

    new IridiumCasper(options)

exports.Iridium = Iridium

exports.create = ->
  new Iridium
