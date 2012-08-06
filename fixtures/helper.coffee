class Helper
  scripts: [
    'qunit',
    'iridium/qunit_adapter',
  ]

  iridium: ->
    _iridium = requireExternal('iridium').create()
    _iridium.scripts = @scripts
    _iridium

exports.casper = ->
  (new Helper).iridium().casper()
