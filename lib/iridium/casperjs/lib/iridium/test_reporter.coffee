window.report = (testResult) ->
  console.log(JSON.stringify({
    signal: 'test',
    data: testResult
  }))

console.message = (msg, level) ->
  @log(JSON.stringify({
    signal: 'log',
    level: level
    data: msg
  }))

console.debug = (msg) ->
  @message msg, 'debug'

console.warn = (msg) ->
  @message msg, 'warn'

console.error = (msg) ->
  @message msg, 'error'
