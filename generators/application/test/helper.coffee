# == Basic Usage ==
#
# This file is the gateway to initializing your test envrionment.
# It must export a casper function which returns a Casper object.
# The casper object is used to run all the tests. You should build your casper
# object by going through Iridium's factory and doing any modification afterward.
# You may specifcy scripts that are sent with every request. This is useful
# when you want to include things for mocking AJAX or things of that nature.
# The scripts array contain relatives paths to these two directories:
#
# 1. Iridium's general JS directory
# 2. Your app's /test folder.
#
# The scripts are injected into the remote DOM in the given order. Files can
# be either Coffeescript or Javascript. Here are some examples:
#
#   iridium = requireExternal('iridium').create()
#
#   iridium.scripts = [
#     # load the unit test framework. This translates to: appliction_root/test/support/qunit.js
#     "support/qunit", 
#
#     # load the qunit adapter from Iridium's internal code base
#     "iridium/qunit_adapter",
#
#     # load custom mocks found in application_root/test/mocking.js
#     "mocking",
#
#     # assume application_root/test/support/logging.coffee exists. 
#     # The extension is not required.
#     "support/logging",
#
#     # files are loaded after your application is ready, so you
#     # can reference files like this:
#     "support/framework_patches"
#   ]
#
#   iridium.casper() # generage a casper instance
#
# == Advanced Usage ==
#
# Iridium contains an addition to casper's runtime. `requireExternal` is used
# to require files outside of casper's library. It uses a traditional load path
# like many other programming languages. It adds two directories to the
# load path:
# 
# 1. Iridium's internal JS directory
# 2. Your app's /test folder.
#
# IMPORTANT NOTE: code required using requireExternal will **not** affect
# code running in the browser. If you want this behavior, then you should
# use the `scripts` attribute on the Iridium factory. You should use
# `requireExternal` when the code to initialize your test env no longer
# makes sense in a single file.
#
# Examples:
#
#   # application_root/test/support/logging.coffee
#   exports.dump = (object) ->
#     console.log(JSON.stringify(object))
#
#   # helper.coffee
#   dump = requireExternal('support/logging').dump
#   iridium = requireExternal('iridium').create()
#
#   exports.casper = (options) ->
#     _casper = iridium.casper(options)
#     _casper.dump = dump  
#     # now you can call casper.dump(object) in your tests
#     _casper
#
#  Your helper begins here...

iridium = requireExternal('iridium').create()

exports.casper = (options) ->
  iridium.scripts = [
    'support/qunit', 
    'iridium/qunit_adapter'
  ]

  iridium.casper(options)
