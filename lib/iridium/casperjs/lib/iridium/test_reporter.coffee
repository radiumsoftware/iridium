window.report = (testResult) ->
  console.log(JSON.stringify({
    signal: 'test',
    foo: 'bar'
    data: testResult
  }))
