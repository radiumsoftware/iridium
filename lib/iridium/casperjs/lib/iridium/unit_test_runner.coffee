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
    casper.test.done()

casper.start casper.unitTestLoader, ->
  for test in @unitTests
    @page.injectJs test

casper.then ->
  @evaluate ->
    window.startTests()

casper.waitFor(
  ->
    casper.evaluate ->
      window.testsDone == true
  , -> 
    casper.test.done()
  , ->
    console.log "Test timed out"
    casper.test.done()
)

casper.run ->
  @test.done()
