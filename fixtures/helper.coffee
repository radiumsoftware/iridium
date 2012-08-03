class Helper
  scripts: [
    'qunit',
    'iridium/qunit_adapter'
    'qunit_tests'
  ]

  iridium: ->
    _iridium = requireExternal('iridium').create()
    _iridium.scripts = @scripts
    _iridium

exports.casper = ->
  (new Helper).iridium().casper()
