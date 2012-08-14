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
  if((request.headers.length == 0 && request.url.match(/file:\/\/.+\.js$/)) || ((request.status == 404 || !request.status) && request.url.match(/https?:\/\/.+\.js$/)))
    result = {}
    result.error = true
    result.message = "Resource Failed to Load: #{request.url}"
    result.backtrace = []
    result.assertions = 0
    logger.message result
    casper.exit()

casper.start casper.cli.get('index'), ->
  for test in @unitTests
    @page.injectJs test

casper.then ->
  @evaluate ->
    window.startUnitTests()

casper.waitFor(
  ->
    casper.evaluate ->
      window.unitTestsDone == true
  , -> 
    casper.test.done()
  , ->
    console.log "Test timed out"
    casper.test.done()
)

casper.run ->
  @test.done()
