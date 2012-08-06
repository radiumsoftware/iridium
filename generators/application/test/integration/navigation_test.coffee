casper.start 'http://localhost:7777/', ->
  @test.assertHttpStatus(200, 'Server is up')

casper.run ->
  @test.done()
