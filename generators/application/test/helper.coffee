# This file is the gateway to initializing your test envrionment.
# It must export a casper function which returns a Casper object.
# The casper object is used to run all the tests. You should build your casper
# object by going through Iridium's factory and doing any modification afterward.
# You may specifcy scripts that are sent with every request. This is useful
# when you want to include things for mocking AJAX or things of that nature.

iridium = requireExternal('iridium').create()

exports.casper = (options) ->
  iridium.scripts = [
    'support/qunit', 
    'iridium/qunit_adapter'
  ]

  iridium.casper(options)
