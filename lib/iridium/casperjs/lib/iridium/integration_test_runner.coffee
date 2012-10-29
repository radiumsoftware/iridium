injectJsStep = (path) ->
  casper.then ->
    if !casper.page.injectJs(path)
      console.abort "Failed to load #{path}!"

startTestStep = (path) ->
  casper.then -> 
    casper.log "Starting integration test: #{path}", "debug"

    @evaluate((file) ->
      window.currentTestFileName = file
      window.startTests()
    , { file: path})

waitForTestStep = (path) ->
  casper.waitFor(
    ->
      casper.log "Checking if #{path} is done...", "debug"

      casper.evaluate ->
        window.testsDone == true
    , -> 
      casper.log "#{path} finished successfully!", "debug"

      # do nothing, the test passed
      true
    , ->
      result = {}
      casper.log "#{path} timed out! You need to debug this in-browser.", "debug"

      result.name = apth
      result.message = "Test timed out"
      result.error = true
      casper.logger.message result
  )

casper.start casper.appURL

for integrationTest in casper.integrationTests
  casper.log "Adding #{integrationTest} to suite", "debug"

  if integrationTest != casper.integrationTests[0]
    casper.then ->
      casper.log "Reloading page to wipe state changes", "debug"
      casper.reload()

  injectJsStep integrationTest

  startTestStep integrationTest

  waitForTestStep integrationTest

casper.run ->
  casper.log "Executing integration tests", "debug"

  @test.done()
