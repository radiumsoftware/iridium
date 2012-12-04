injectJsStep = (path) ->
  casper.then ->
    if !casper.page.injectJs(path)
      phantom.abort "Failed to load #{path}!"

startTestStep = (path) ->
  casper.then -> 
    phantom.logger.info "Starting integration test: #{path}"

    @evaluate((file) ->
      window.currentTestFileName = file
      window.startTests()
    , { file: path})

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

casper.start casper.appURL

for integrationTest in casper.integrationTests
  phantom.logger.info "Adding #{integrationTest} to suite"

  if integrationTest != casper.integrationTests[0]
    casper.then ->
      phantom.logger.info "Reloading page to wipe state changes"
      casper.reload()

  injectJsStep integrationTest

  startTestStep integrationTest

  waitForTestStep integrationTest

casper.run ->
  phantom.logger.info "Executing integration tests"
  @test.done()
