# PhantomJS QUnit Test Runner

args = phantom.args

if args.length < 1
  console.log "Usage: " + phantom.scriptName + " <URL> <timeout>"
  phantom.exit 1

print = (str) ->
  fs.write "/dev/stdout", str, "w"

phantom.debug = args.indexOf("--debug") >= 0

fs = require("fs")
page = require("webpage").create()

page.settings.userAgent = "phantom"

page.onConsoleMessage = (msg, lineNum, source) ->
  return if msg.slice(0, 8) is "WARNING:"

  # Hack to access the print method
  # If there's a better way to do this, please change
  if msg.slice(0, 6) is "PRINT:"
    print msg.slice(7)

  # pass --debug to enable remote console
  else if phantom.debug
    console.log msg

page.open args[0], (status) ->
  if status isnt "success"
    console.error "Unable to access network"
    phantom.exit 1

  console.log "Running Tests:\n"

  testFramework = page.evaluate ->
    if typeof QUnit != "undefined"
      "qunit"
    else if typeof window.jasmine != "undefined"
      "jasmine"
    else
      undefined

  switch testFramework
    when "qunit"
      page.evaluate qunitAdapter
    when "jasmine"
      page.evaluate jasmineAdapter
    else
      console.log "Unkown test framework!"
      phantom.exit 124

  timeout = parseInt(args[1] or 60000, 10)
  start = Date.now()

  interval = setInterval(->
    if Date.now() > start + timeout
      console.error "Tests timed out"
      phantom.exit 124
    else
      testsDone = page.evaluate ->
        window.testsDone

      if testsDone
        clearInterval interval

        testResults = page.evaluate ->
          window.testResults

        printResults testResults

        passedCount = 0
        testResults.forEach (result) ->
          passedCount++ unless result.failed
        testsPassed = passedCount is testResults.length

        if testsPassed
          phantom.exit 0
        else
          phantom.exit 1
  , 500)

printResults = (results) ->
  console.log "\n"

  for result in results when result.failed
    if result.group
      console.log "#{result.group}: #{result.name}"
    else
      console.log result.name

    console.log "  #{result.message}"

    if result.backtrace.length > 0
      console.log ""

      for line in result.backtrace
        console.log "  #{line}"

    console.log ""
    console.log ""

  total = results.length
  passed = 0
  results.forEach (result) ->
    passed++ unless result.failed
  failed = total - passed

  console.log "Total: #{total}, Passed: #{passed}, Failed: #{failed}"

qunitAdapter = ->
  # Setup the DOM unless the loader does it
  unless document.getElementById "qunit"
    container = document.createElement 'div'
    container.setAttribute "id", "qunit"
    document.body.insertBefore container, document.body.firstChild

  unless document.getElementById "qunit-fixture"
    fixture = document.createElement 'div'
    fixture.setAttribute "id", "qunit-fixture"
    document.body.insertBefore fixture, document.body.firstChild

  @currentTest = {}
  @results = []

  QUnit.testStart (context) =>
    @currentTest = {}
    @currentTest.file = window.currentTestFileName
    @currentTest.name = context.name
    @currentTest.backtrace = []
    @currentTest.group = context.module

  QUnit.log (context) => 
    if context.result
      return

    stackTrace = []
    @currentTest.backtrace = []

    # qunit handles exceptions in a werid way. It prepends "Died" 
    # to the stacktrace and shoves that in message
    if context.message.match(/^Died/)
      @currentTest.failed = true
      @currentTest.message = context.source
      stackTrace = context.message

    # General Assertion Error
    else if context.message
      @currentTest.failed = true
      @currentTest.message = context.message
      stackTrace = context.source

    # Failed expectations
    else if context.expected
      @currentTest.failed = true
      @currentTest.message = "Expected: #{context.expected}, Actual: #{context.actual}"
      stackTrace = context.source

    # format the backtrace accordingly
    for line in stackTrace.split("\n").reverse()
      matches = line.match /((?:file:\/\/|https?:\/\/).+$)/
      if matches
        @currentTest.backtrace.push matches[1]
      else
        @currentTest.backtrace.push line

  QUnit.testDone (context) => 
    @results.push @currentTest

    if @currentTest.failed 
      console.log 'PRINT: F'
    else
      console.log 'PRINT: .'

  QUnit.done (context) =>
    window.testsDone = true
    window.testResults = @results

jasmineAdapter = ->
  class PhantomReporter
    constructor: ->
      @results = []
      @test = {}

    reportSpecStarting: (spec) ->
      @test = {}
      @test.backtrace = []
      @test.name = spec.getFullName()

    reportSpecResults: (spec) ->
      results = spec.results()

      @test.failed = results.failedCount > 0
      @test.skipped = results.skipped

      if @test.failed
        failures = results.items_.filter (item) ->
          item.passed_ == false

        failure = failures[0]

        @test.message = failure.message

        # format the backtrace accordingly
        if failure.trace.stack
          for line in failure.trace.stack.split("\n")
            matches = line.match /((?:file:\/\/|https?:\/\/).+$)/
            if matches
              @test.backtrace.push matches[1]
            else
              @test.backtrace.push line

      @results.push @test

      if @test.failed
        console.log "PRINT: F"
      else if @test.skipped
        console.log "PRINT: S"
      else
        console.log "PRINT: ."

    reportRunnerResults: (results) ->
      window.testsDone = true
      window.testResults = @results

  window.jasmine.getEnv().addReporter(new PhantomReporter())
  window.jasmine.getEnv().execute()
