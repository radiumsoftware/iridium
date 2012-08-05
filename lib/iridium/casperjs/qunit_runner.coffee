fs = require('fs')
utils = require('utils')

unless phantom.casperArgs.get('I')
  console.log("No Load paths passed!")
  phantom.exit(2)

window.testMode = 'unit'
window.loadPaths = phantom.casperArgs.get('I').split(',')
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
iridium.Iridium::root = @window.loadPaths[0]
iridium.Iridium::testRoot = @window.loadPaths[1]

casper = requireExternal('helper').casper()

casper.on 'page.error', (error, trace) ->
  console.log(error)
  utils.dump(trace)
  casper.exit(2)

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

    console.log("<iridium>#{JSON.stringify(result)}</iridium>")
    casper.exit()

casper.start casper.cli.args[0], ->
  console.log "Starting tests on: #{casper.cli.args[0]}"
  casper.evaluate ->
    QUnit.load()

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
