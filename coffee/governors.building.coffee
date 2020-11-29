'use strict'

Gov = require 'governors'


class BuildingGov extends Gov
  Gov.variants[@name] = @

  constructor: (room, opts) ->
    super(room, opts)

  start: ->
  updateEdicts: ->
  finish: ->


module.exports = BuildingGov
