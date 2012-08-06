fs = require('fs')

unless phantom.casperArgs.get('lib-path')
  console.log("--lib-path is required!")
  phantom.exit(2)

unless phantom.casperArgs.get('test-path')
  console.log("--test-path")
  phantom.exit(2)

window.testMode = 'unit'
window.loadPaths = [phantom.casperArgs.get('lib-path'), phantom.casperArgs.get('test-path')]
window.requireExternal = (path) ->
  for directory in loadPaths
    if fs.exists(fs.pathJoin(directory, "#{path}.coffee")) || fs.exists(fs.pathJoin(directory, "#{path}.js")) 
      return require(fs.pathJoin(directory, path))

  console.log "#{path} could not be found in #{loadPaths}"
  phantom.exit(2)

# Hooray! Now we have an iridium object
iridium = requireExternal('iridium')

# Assign the root and test root to the prototype so all new iridium
# objects will know where they are
iridium.Iridium::mode = 'integration'
iridium.Iridium::root = @window.loadPaths[0]
iridium.Iridium::testRoot = @window.loadPaths[1]

casper = requireExternal('helper').casper({
  exitOnError: false
})

tests = casper.cli.args

for test in tests 
  absolutePath = fs.absolute(test)
  unless fs.isFile(absolutePath)
    console.log "#{absolutePath} does not exist!"
    phantom.exit(2)

@casper = casper

# run all the suites
casper.test.runSuites.apply(casper.test, tests)
