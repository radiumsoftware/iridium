if (!phantom.casperLoaded) {
  console.log('This script must be invoked using the casperjs executable');
  phantom.exit(1);
}

var colorizer = require('colorizer');
var fs = require('fs');
var utils = require('utils');
var f = utils.format;
var includes = [];
var tests = [];
var casper = require('casper').create({
    exitOnError: false
});

// local utils
function checkIncludeFile(include) {
  var absInclude = fs.absolute(include.trim());
  if (!fs.exists(absInclude)) {
    casper.warn("%s file not found, can't be included", absInclude);
    return;
  }
  if (!utils.isJsFile(absInclude)) {
    casper.warn("%s is not a supported file type, can't be included", absInclude);
    return;
  }
  if (fs.isDirectory(absInclude)) {
    casper.warn("%s is a directory, can't be included", absInclude);
    return;
  }
  if (tests.indexOf(include) > -1 || tests.indexOf(absInclude) > -1) {
    casper.warn("%s is a test file, can't be included", absInclude);
    return;
  }
  return absInclude;
}

// parse some options from cli
casper.options.verbose = casper.cli.get('direct') || false;
casper.options.logLevel = casper.cli.get('log-level') || "error";
var cls = 'Dummy';
casper.options.colorizerType = cls;
casper.colorizer = colorizer.create(cls);

// test paths are passed as args
if (casper.cli.args.length) {
  tests = casper.cli.args.filter(function(path) {
    return fs.isFile(path) || fs.isDirectory(path);
  });
} else {
  casper.echo('No test path passed, exiting.', 'RED_BAR', 80);
  casper.exit(1);
}

// includes handling
if (casper.cli.has('includes')) {
  includes = casper.cli.get('includes').split(',').map(function(include) {
    // we can't use filter() directly because of abspath transformation
    return checkIncludeFile(include);
  }).filter(function(include) {
    return utils.isString(include);
  });
  casper.test.includes = utils.unique(includes);
}

// Redfine the runTest method to emit an event we can list to
casper.test.runTest = function runTest(testFile) {
  this.emit("test.started", testFile);
  this.running = true; // this.running is set back to false with done()
  this.exec(testFile);
};

// register listeners needed to capture events
// to generate results to pass back to Iridium
var currentTest;
var startTime;

// Patch the test.done method to emit the done event
// so we can print test results in real time.
// This functionality should make it into the 1.0 release.
//
// It was added in this commit: 
// https://github.com/n1k0/casperjs/commit/4eee81406c1e672eec58ca8c80e336ab2863e988
casper.test.done = function done() {
  this.emit('test.done');
  this.running = false;
};

casper.test.on('test.started', function(testFile) {
  startTime = (new Date()).getTime();
  currentTest = {};
  currentTest.assertions = 0;
  currentTest.name = testFile;
});

casper.test.on('success', function() {
  currentTest.assertions++;
});

casper.test.on('fail', function(failure) {
  if(failure.type === 'uncaughtError') {
    currentTest.error = true;
    currentTest.message = failure.message;
    currentTest.backtrace = [failure.file + ":" + failure.line]
  } else {
    currentTest.assertions++;
    currentTest.failed = true
    currentTest.message = failure.type + ": " + (failure.message || failure.standard || "(no message was entered)");
    currentTest.backtrace = [failure.file]
    casper.test.done();
  }
});

casper.test.on('test.done', function() {
  currentTest.time = (new Date().getTime()) - startTime;
  console.log("<iridium>" + JSON.stringify(currentTest) + "</iridium>");
});

casper.test.on('tests.complete', function() {
  var exitStatus = ~~(status || (this.testResults.failed > 0 ? 1 : 0));
  casper.exit(exitStatus);
});

// run all the suites
casper.test.runSuites.apply(casper.test, tests);
