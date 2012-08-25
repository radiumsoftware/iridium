fs = require('fs')
utils = require('utils')

console.abort = (msg) ->
  @log(JSON.stringify({abort: msg}))

console.dump = (object) ->
  @log(JSON.stringify(object))

unless phantom.casperArgs.get('lib-path')
  console.abort("--lib-path is required!")
  phantom.exit()

unless phantom.casperArgs.get('test-path')
  console.abort("--test-path is required!")
  phantom.exit()

window.loadPaths = [phantom.casperArgs.get('lib-path'), phantom.casperArgs.get('test-path')]
window.requireExternal = (path) ->
  for directory in loadPaths
    if fs.exists(fs.pathJoin(directory, "#{path}.coffee")) || fs.exists(fs.pathJoin(directory, "#{path}.js")) 
      return require(fs.pathJoin(directory, path))

  console.abort "#{path} could not be found in #{loadPaths}"
  phantom.exit()

# Hooray! Now we have an iridium object
iridium = requireExternal('iridium')

# Assign the root and test root to the prototype so all new iridium
# objects will know where they are
iridium.Iridium::root = loadPaths[0]
iridium.Iridium::testRoot = loadPaths[1]

testFiles = phantom.casperArgs.args

unitTests = []
integrationTests = []
casperTests = []

for test in testFiles
  absolutePath = fs.absolute(test)

  unless fs.isFile(absolutePath)
    console.abort "#{absolutePath} does not exist!"
    phantom.exit()

  if test.match(/casper\//)
    casperTests.push test
  else if test.match(/integration\//)
    integrationTests.push test
  else
    unitTests.push test

unitTestRunner = fs.pathJoin(loadPaths[0], "iridium", "unit_test_runner.coffee")
integrationTestRunner = fs.pathJoin(loadPaths[0], "iridium", "integration_test_runner.coffee")

casper = iridium.casper({
  exitOnError: false
})

casper.unitTests = unitTests
casper.integrationTests = integrationTests
casper.unitTestLoader = casper.cli.get('index')

casperTests.push unitTestRunner if unitTests.length > 0
casperTests.push integrationTestRunner if integrationTests.length > 0

@casper = casper

casper.test.runSuites.apply(casper.test, casperTests)
