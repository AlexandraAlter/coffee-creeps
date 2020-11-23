'use strict'


Gov = require 'governors.base'


class CombatGov extends Gov
  Gov.variants[@name] = @

  constructor: () ->
    super()

  start: ->
  makeSpawnRequests: ->
  makeJobRequests: ->
  finish: ->



module.exports = CombatGov
