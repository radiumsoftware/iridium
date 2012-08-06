fs = require('fs')
utils = require('utils')

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
iridium.Iridium::root = loadPaths[0]
iridium.Iridium::testRoot = loadPaths[1]

logger = requireExternal('iridium/logger').create()

casper = requireExternal('helper').casper()

tests = casper.cli.args

for test in tests 
  absolutePath = fs.absolute(test)
  unless fs.isFile(absolutePath)
    console.log "#{absolutePath} does not exist!"
    phantom.exit(2)

casper.on 'page.error', (error, trace) ->
  result = {}
  result.name = "Uncaught error"
  result.message = error
  result.backtrace = casper.formatBacktrace(trace)
  result.error = true
  logger.message result


casper.on 'resource.received', (request) ->
  return if request.stage == 'start'

  # blow up if a requested script 404's
  # We can check for the 404 response code for http requests
  # file:// requests have no bodySize.
  if((request.headers.length == 0 && request.url.match(/file:\/\/.+\.js$/)) || (request.status == 404 && request.url.match(/https?:\/\/.+\.js$/)))
    result = {}
    result.error = true
    result.message = "Resource Failed to Load: #{request.url}"
    result.backtrace = []
    result.assertions = 0
    logger.message result
    casper.exit()

casper.start casper.cli.get('index'), ->
  for test in tests
    @page.injectJs test

casper.then ->
  @evaluate ->
    window.startUnitTests()

casper.waitFor(
  ->
    casper.evaluate ->
      window.unitTestsDone == true
  , -> 
    casper.exit
  , ->
    console.log "Test timed out"
    casper.exit(124)
)

casper.run()
