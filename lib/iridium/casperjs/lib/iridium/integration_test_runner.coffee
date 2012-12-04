setCurrentTestStep = (path) ->
  casper.then -> 
    @currentTestFile = path

injectJsStep = (path) ->
  casper.then ->
    if !casper.page.injectJs(path)
      phantom.abort "Failed to load #{path}!"

startTestStep = (path) ->
  casper.then -> 
    console.info "Starting integration test: #{path}"

    @currentTestFile = path
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
      console.info "#{path} finished successfully!"

      # do nothing, the test passed
      true
    , ->
      console.info "#{path} timed out! You need to debug this in-browser."

      phantom.report
        name: path
        message: "Test timed out"
        error: true
  )

casper.start casper.appURL

for integrationTest in casper.integrationTests
  console.info "Adding #{integrationTest} to suite"

  setCurrentTestStep integrationTest

  if integrationTest != casper.integrationTests[0]
    casper.then ->
      console.info "Reloading page to wipe state changes"
      casper.reload()

  injectJsStep integrationTest

  startTestStep integrationTest

  waitForTestStep integrationTest

casper.run ->
  console.info "Executing integration tests"
  @test.done()
