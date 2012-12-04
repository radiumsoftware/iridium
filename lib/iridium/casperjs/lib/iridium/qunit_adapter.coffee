@currentTest = {}
@startTime = null

QUnit.testStart (context) =>
  @currentTest = {}
  @currentTest.file = window.currentTestFileName
  @currentTest.name = context.name
  @currentTest.assertions = 0
  @currentTest.backtrace = []
  @startTime = (new Date()).getTime()

QUnit.log (context) => 
  if context.result
    @currentTest.assertions++
    return

  stackTrace = []
  @currentTest.backtrace = []

  # qunit handles exceptions in a werid way. It prepends "Died" 
  # to the stacktrace and shoves that in message
  if context.message.match(/^Died/)
    @currentTest.error = true
    @currentTest.message = context.source
    stackTrace = context.message

  else if context.message.match(/(Setup|Teardown) failed/)
    @currentTest.error = true
    @currentTest.message = context.message
    stackTrace = context.source

  # General Assertion Error
  else if context.message
    @currentTest.assertions++
    @currentTest.failed = true
    @currentTest.message = context.message
    stackTrace = context.source

  # Failed expectations
  else if context.expected
    @currentTest.failed = true
    @currentTest.message = "Expected: #{context.expected}, Actual: #{context.actual}"
    stackTrace = context.source

  # format the backtrace accordingly
  for line in stackTrace.split("\n")
    matches = line.match(/(file:\/\/|https?:\/\/|\/.+:\d+)/)
    if matches
      @currentTest.backtrace.push matches[1]
    else
      @currentTest.backtrace.push line

QUnit.testDone (context) => 
  @currentTest.time = (new Date()).getTime() - @startTime
  window.testDone = true
  window.report @currentTest

QUnit.done (context) =>
  window.testsDone = true

QUnit.config.autorun = false

window.startTests = ->
  window.testsDone = false

  container = document.createElement('div')
  container.setAttribute "id", "qunit"
  document.body.insertBefore container, document.body.firstChild

  fixture = document.createElement('div')
  fixture.setAttribute "id", "qunit-fixture"
  document.body.insertBefore fixture, document.body.firstChild

  QUnit.load()
