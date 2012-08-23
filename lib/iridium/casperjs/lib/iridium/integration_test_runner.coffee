casper.start casper.appURL

injectJsStep = (path) ->
  casper.then ->
    casper.page.injectJs path

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

for integrationTest in casper.integrationTests
  casper.then ->
    casper.reload()

  injectJsStep integrationTest

  casper.then ->
    @evaluate ->
      window.startTests()

  waitForTestStep integrationTest

casper.run ->
  @test.done()
