window.report = (testResult) ->
  console.log(JSON.stringify({
    signal: 'test',
    data: testResult
  }))
