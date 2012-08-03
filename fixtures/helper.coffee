class Helper
  scripts: [
    'iridium/qunit'
  ]

  iridium: ->
    _iridium = requireExternal('iridium').create()
    _iridium.includes = @scripts
    _iridium

exports.Helper = Helper

exports.create = ->
  new Helper

exports.iridium = ->
  @create().iridium()
