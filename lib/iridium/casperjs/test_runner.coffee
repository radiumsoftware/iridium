fs = require('fs')
utils = require('utils')

phantom.abort = (msg) ->
  console.log(JSON.stringify({
    signal: 'abort',
    message: msg
  }))
  @exit()

# Create a logger we can use to communicate message
# back to iridium. The casper logger delegates to this
# class. This ensures that all messages that need
# be sent back go through the same entry point.
#
# The following log levels are supported
# * debug
# * info
# * warning
# * error
class Logger
  debug: (msg) ->
    @log 'debug', msg

  info: (msg) ->
    @log 'info', msg

  warning: (msg) ->
    @log 'warning', msg

  error: (msg) ->
    @log 'error', msg

  log: (level, msg) ->
    console.log(JSON.stringify({
      signal: 'log',
      level: level,
      message: msg
    }))

# Debug logging
phantom.logger = new Logger()

# Pass test results back to the ruby process
phantom.report = (test) ->
  console.log(JSON.stringify({
    signal: 'test',
    message: test
  }))

unless phantom.casperArgs.get('lib-path')
  phantom.abort("--lib-path is required!")

window.loadPaths = [phantom.casperArgs.get('lib-path')]
window.requireExternal = (path) ->
  for directory in loadPaths
    if fs.exists(fs.pathJoin(directory, "#{path}.coffee")) || fs.exists(fs.pathJoin(directory, "#{path}.js")) 
      return require(fs.pathJoin(directory, path))

  phantom.abort "#{path} could not be found in #{loadPaths}"

# Hooray! Now we have an iridium object
iridium = requireExternal('iridium')

# Assign the root and test root to the prototype so all new iridium
# objects will know where they are
iridium.Iridium::root = loadPaths[0]

# now assign the support Files
if phantom.casperArgs.get('support-files')
  iridium.Iridium::supportFiles = phantom.casperArgs.get('support-files').split(',')
else
  iridium.Iridium::supportFiles = []

testFiles = phantom.casperArgs.args

unitTests = []
integrationTests = []
casperTests = []

for test in testFiles
  absolutePath = fs.absolute(test)

  unless fs.isFile(absolutePath)
    phantom.abort "#{absolutePath} does not exist!"

  if test.match(/casper\//)
    casperTests.push test
  else if test.match(/integration\//)
    integrationTests.push test
  else
    unitTests.push test

unitTestRunner = fs.pathJoin(loadPaths[0], "iridium", "unit_test_runner.coffee")
integrationTestRunner = fs.pathJoin(loadPaths[0], "iridium", "integration_test_runner.coffee")

options = {
  exitOnError: false
}

# This is independant of logging. This is an internal flag
# to cause casper to spit out pretty much every single thing
# it does. Flip this swith in the test are run in debug
# mode. This will dump internal casper state as well
# as iridium's
options.verbose = phantom.casperArgs.get('log-level') == 'debug'

# Default to warning so we don't things like steps being
# in the log by default
options.logLevel = phantom.casperArgs.get('log-level') || 'warning'

casper = iridium.casper options

# assign the arrays of test case files so they can
# be accessed inside the unit and integration test runners
casper.unitTests = unitTests
casper.integrationTests = integrationTests

casper.unitTestLoader = casper.cli.get('index')

casperTests.push unitTestRunner if unitTests.length > 0
casperTests.push integrationTestRunner if integrationTests.length > 0

@casper = casper

casper.test.runSuites.apply(casper.test, casperTests)
