casper.start "http://www.google.com/ncr", ->
  @test.assert true
  @test.assertTitle "Google", "google homepage title is the one expected"
  @test.assertExists 'form[action="/search"]', "main form is found"
  @fill 'form[action="/search"]', q: "foo", true

casper.then ->
  @test.assertUrlMatch /q=foo/, "search term has been submitted"
  @test.assertEval (->
      __utils__.findAll("h3.r").length >= 10
  ), "google search for \"foo\" retrieves 10 or more results"

casper.run ->
  @test.done()
