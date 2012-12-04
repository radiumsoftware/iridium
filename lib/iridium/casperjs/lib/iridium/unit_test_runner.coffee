casper.on 'resource.received', (request) ->
  return if request.stage == 'start'

  # blow up if a requested script 404's
  # We can check for the 404 response code for http requests
  # file:// requests have no bodySize.
  if((request.headers.length == 0 && request.url.match(/file:\/\/.+\.js$/)) || ((request.status == 404 || !request.status) && request.url.match(/https?:\/\/.+\.js$/)))
    phantom.logger.info "Test failed because #{request.url} did not return properly"

    phantom.report
      error: true
      message: "Resource Failed to Load: #{request.url}"
      backtrace: []
      assertions: 0

    casper.test.done()

setCurrentTestStep = (path) ->
  casper.then -> 
    @currentTestFile = path

injectJsStep = (path) ->
  casper.then ->
    if !casper.page.injectJs(path)
      phantom.abort "Failed to load #{path}!"

waitForTestStep = (path) ->
  casper.waitFor(
    ->
      casper.evaluate ->
        window.testsDone == true
    , -> 
      phantom.logger.info "#{path} finished successfully!"

      # do nothing, the test passed
      true
    , ->
      phantom.logger.info "#{path} timed out! You need to debug this in-browser."

      phantom.report
        name: path
        message: "Test timed out"
        error: true
  )

startTestStep = (path) ->
  casper.then -> 
    @currentTestFile = path
    @evaluate((file) ->
      window.currentTestFileName = file
      window.startTests()
    , { file: path})


casper.start casper.unitTestLoader

for unitTest in casper.unitTests
  phantom.logger.info "Adding: #{unitTest} to the test suite"

  setCurrentTestStep unitTest

  casper.then ->
    phantom.logger.info "Reloading page to wipe state"
    casper.reload()

  injectJsStep unitTest

  startTestStep unitTest

  waitForTestStep unitTest

casper.run ->
  phantom.logger.info "Executing unit tests"

  @test.done()
