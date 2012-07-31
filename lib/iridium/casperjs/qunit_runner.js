if (!phantom.casperLoaded) {
  console.log('This script must be invoked using the casperjs executable');
  phantom.exit(1);
}

function logQUnit() {
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
      currentTest.message = context.message;
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
    window.qunitDone = true;
  });
}

var casper = require('casper').create();

// Connect the client console to this
// console
casper.on('remote.message', function(msg) {
  console.log(msg);
});

casper.on('resource.received', function(request) {
  if(request.stage === 'start') return;

  // blow up if a requested script 404's
  // We can check for the 404 response code for http requests
  // file:// requests have no bodySize.
  if((request.headers.length == 0 && request.url.match(/file:\/\/.+\.js$/)) || (request.status === 404 && request.url.match(/https?:\/\/.+\.js$/))) {
    result = {}
    result.error = true;
    result.message = "Resource Failed to Load: " + request.url
    result.backtrace = []

    console.log("<iridium>" + JSON.stringify(result) + "</iridium>");
    casper.exit();
  }
});

casper.on('load.finished', function() {
  casper.evaluate(logQUnit);
});

casper.start(casper.cli.args[0]);

casper.waitFor(function() {
  return casper.evaluate(function() {
    return window.qunitDone === true;
  });
  }, function() {
    casper.exit();
  }, function() {
    console.log("Tests timed out");
    casper.exit(124);
  }
);

casper.run();
