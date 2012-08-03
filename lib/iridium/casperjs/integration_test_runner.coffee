fs = require('fs')

window.testMode = 'integration'
window.loadPaths = phantom.casperArgs.get('I').split(',')
window.requireExternal = (path) ->
  for directory in loadPaths
    if fs.exists(fs.pathJoin(directory, "#{path}.coffee")) || fs.exists(fs.pathJoin(directory, "#{path}.js")) 
      return require(fs.pathJoin(directory, path))

  throw "#{path} could not be found in #{loadPaths}"

# Hooray! Now we have an iridium object
iridium = requireExternal('iridium')

# Assign the root and test root to the prototype so all new iridium
# objects will know where they are
iridium.Iridium::root = @window.loadPaths[0]
iridium.Iridium::testRoot = @window.loadPaths[1]

tests = []

casper = requireExternal('helper').casper({
  exitOnError: true
})

# test paths are passed as args
if (casper.cli.args.length)
  tests = casper.cli.args.filter (path) ->
    fs.isFile(path) || fs.isDirectory(path)
else
  console.log('No test files!')
  casper.exit(1)

@casper = casper

# run all the suites
casper.test.runSuites.apply(casper.test, tests)
