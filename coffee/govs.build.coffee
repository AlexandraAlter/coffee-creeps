'use strict'

govs = require 'govs'


class BuildGov extends govs.Gov
  @addVariant()

  constructor: (room, opts) ->
    super(room, opts)

  start: ->
  updateEdicts: ->
  finish: ->


module.exports = {
  BuildGov
}
