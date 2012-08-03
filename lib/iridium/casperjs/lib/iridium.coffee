# This file defines the Iridium object. It holds configuration
# need for tests. It also defines a new Casper object to use
# for integration tests. It also makes two values available 
# globally through the Iridum object:
#
# 1. The Iridium load path (core files)
# 2. The test support load path (app files)
#
# This files makes it possible to have a local `test_helper.js`
# to define your own functionality and set includes
class Iridium
  @env = "test"
  @includes = []
  @message = (msg) ->
    console.log "<iridium>#{JSON.stringify(msg)}</iridium>"

exports.Iridium = Iridium

exports.create = ->
  new Iridium
