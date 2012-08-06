class Helper
  scripts: [
    'support/qunit',
    'iridium/qunit_adapter',
  ]

  iridium: ->
    _iridium = requireExternal('iridium').create()
    _iridium.scripts = @scripts
    _iridium

exports.casper = (options) ->
  (new Helper).iridium().casper(options)
