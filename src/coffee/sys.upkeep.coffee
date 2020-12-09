'use strict'

log = require 'log'
Zone = require 'zone'
Node = require 'node'
Cortex = require 'cortex'

logger = log.getLogger 'sys.upkeep'
l = log.fmt


class UpkeepNode extends Node
  @rehydrator.register @


class UpkeepCortex extends Cortex
  @defineMemory ['sys', 'upkeep']

  reload: ->
    for zone in @sys.zones
      if not (zone.nodes.some (n) -> n instanceof UpkeepNode)
        zone.addNode new UpkeepNode 'upkeep', zone, {}


module.exports = {
  toString: -> '[module sys.upkeep]'
  UpkeepNode
  UpkeepCortex
}
