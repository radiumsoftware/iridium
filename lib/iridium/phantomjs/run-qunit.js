var args = phantom.args;

if (args.length < 1 || args.length > 2) {
  console.log("Usage: " + phantom.scriptName + " <URL> <timeout>");
  phantom.exit(1);
}

var page = require('webpage').create();

page.onConsoleMessage = function(msg) {
  if (msg.slice(0,8) === 'WARNING:') { return; }
  console.log(msg);
};

page.open(args[0], function(status) {
  if (status !== 'success') {
    console.error("Unable to access network");
    phantom.exit(1);
  } else {
    page.evaluate(logQUnit);

    var timeout = parseInt(args[1] || 500, 10);
    var start = Date.now();
    var interval = setInterval(function() {
      if (Date.now() > start + timeout) {
        console.error("Tests timed out");
        phantom.exit(124);
      } else {
        var qunitDone = page.evaluate(function() {
          return window.qunitDone;
        });

        if (qunitDone) {
          clearInterval(interval);
          phantom.exit();

          if (qunitDone.failed > 0) {
            phantom.exit(1);
          } else {
            phantom.exit();
          }
        }
      }
    }, 250);
  }
});

function logQUnit() {
  var testResults = [];
  var currentTest = {};
  var startTime;

  QUnit.testStart(function(context) {
    currentTest = {};
    currentTest.name = context.name;
    currentTest.assertions = 0;
    startTime = (new Date()).getTime();
  });

  QUnit.log(function(context) {
    currentTest.assertions++;

    if(context.result) return;

    var stackTrace;
    currentTest.backtrace = [];

    // qunit handles exceptions in a werid way. It prepends "Died" 
    // to the stacktrace and shoves that in message
    if(context.message.match(/^Died/)) {
      currentTest.error = true;
      currentTest.message = context.source;
      stackTrace = context.message;

    // General Assertion Error
    } else if(context.message) {
      currentTest.failed = true;
      currentTest.message = context.message
      stackTrace = context.source;

    // Failed expectations
    } else if(context.expected) {
      currentTest.failed = true;
      currentTest.message = "Expected: " + context.expected + ", Actual: " + context.actual
      stackTrace = context.source;
    }

    var lines = stackTrace.split("\n");
    for(var i = 0; i < lines.length; i++) {
      currentTest.backtrace.push(lines[i].match(/(file:\/\/\/.+:\d+)/)[1]);
    }

  });

  QUnit.testDone(function(context) {
    currentTest.time = (new Date()).getTime() - startTime;
    console.log("<iridium>" + JSON.stringify(currentTest) + "</iridium>");
  });

  QUnit.done(function(context) {
    window.qunitDone = context;
  });
}
