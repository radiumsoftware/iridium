casper.start 'casper.appURL', ->
  @test.assertHttpStatus(200, 'Server is up')

casper.run ->
  @test.done()
