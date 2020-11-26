'use strict'

Gov = require 'governors.base'


class BuildingGov extends Gov
  Gov.variants[@name] = @

  constructor: (room, opts) ->
    super(room, opts)

  start: ->
  updateEdicts: ->
  finish: ->


module.exports = BuildingGov
