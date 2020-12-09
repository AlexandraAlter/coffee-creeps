'use strict'

Core = require 'core'
Backoff = require 'backoff'
Node = require 'node'
freq = require 'freq'
log = require 'log'

logger = log.getLogger 'cortex'
l = log.fmt


class Cortex extends Core
  constructor: () ->
    super()
    freq.onSafety =>
      throw Error 'Cortex is virtual' if @constructor is Cortex
    @nodes = []

  requirements: -> {}

  reload: ->
    @nodes = for zone of @sys.zones
      zone.nodes

  refresh: ->
    if @requirements?
      for zone in @sys.zones
        for type, func of @requirements()
          if not (zone.nodes.some (n) -> n instanceof type)
            zone.addNode func(zone)


module.exports = Cortex
