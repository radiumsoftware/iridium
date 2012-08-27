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

injectJsStep = (path) ->
  casper.then ->
    if !casper.page.injectJs(path)
      console.abort "Failed to load #{path}!"

waitForTestStep = (path) ->
  casper.waitFor(
    ->
      casper.evaluate ->
        window.testsDone == true
    , -> 
      # do nothing, the test passed
      true
    , ->
      result = {}
      result.name = apth
      result.message = "Test timed out"
      result.error = true
      casper.logger.message result
  )

startTestStep = (path) ->
  casper.then -> 
    @evaluate((file) ->
      window.currentTestFileName = file
      window.startTests()
    , { file: path})

casper.start casper.unitTestLoader

for unitTest in casper.unitTests
  casper.then ->
    casper.reload()

  injectJsStep unitTest

  startTestStep unitTest

  waitForTestStep unitTest

casper.run ->
  @test.done()
