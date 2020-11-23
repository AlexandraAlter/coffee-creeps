'use strict'


Gov = require 'governors.base'


class BuildingGov extends Gov
  Gov.variants[@name] = @

  constructor: () ->
    super()

  start: ->
  updateEdicts: ->
  finish: ->


module.exports = BuildingGov
