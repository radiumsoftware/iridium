class Logger
  message: (msg) ->
    console.log(JSON.stringify({iridium: msg}))

window.logger = new Logger
