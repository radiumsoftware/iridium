injectJsStep = (path) ->
  casper.then ->
    if !casper.page.injectJs(path)
      console.abort "Failed to load #{path}!"

startTestStep = (path) ->
  casper.then -> 
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
      # do nothing, the test passed
      true
    , ->
      result = {}
      result.name = apth
      result.message = "Test timed out"
      result.error = true
      casper.logger.message result
  )

casper.start casper.appURL

for integrationTest in casper.integrationTests

  if integrationTest != casper.integrationTests[0]
    casper.then ->
      casper.reload()

  injectJsStep integrationTest

  startTestStep integrationTest

  waitForTestStep integrationTest

casper.run ->
  @test.done()
