'use strict'

_ = require 'lodash'
log = require 'log'
Core = require 'core'
Node = require 'node'
Backoff = require 'backoff'
freq = require 'freq'

logger = log.getLogger 'zone'
l = log.fmt


class Zone extends Core.Backed
  @backingCls = Room

  @defineMemory 'memPath'

  constructor: (backing) ->
    super backing
    @name = @backing.name
    @memPath = ['rooms', @name]
    @nodes = []
    @workers = []

  toString: -> super()[...-1] + " #{@name}]"

  fetchBacking: -> Game.rooms[@name]

  addNode: (node) -> @nodes.push node
  remNode: (node) -> _.pull @nodes, node
  getNode: (nodeCls) -> _.filter @nodes, (n) -> n instanceof nodeCls

  iterChildren: ->
    if @nodes?
      yield node for node in @nodes

  reload: ->
    @nodes = _.compact(
      for name, mem of @memory
        if name? and mem?
          Node.rehydrator.fromIfValid name, @, mem)


# Room::init = ->
#   @backoff.with ->
#     freq.onReload =>
#       @initFirstTime()
#     logger.trace "init for #{@}"
#     for gName, gov of @memory.governors
#       @memory.governors[gName] = Gov.newFromMem @, gov
#     return


# Room::reset = ->


# Room::tick = ->
#   @backoff = new Backoff @
#   @init()


# cleanMemory = ->
#   logger.info 'cleaning rooms'
#   for rName of Memory.rooms
#     if not Game.rooms[rName]?
#       delete Memory.rooms[rName]


# tick = ->
#   for rName, room of Game.rooms
#     room.init()

#     freq.onRareOrReload 0, =>
#       logger.info l"refreshing govs in #{room}"
#       logger.withIndent =>
#         Gov.allVariants.delIfRequired room
#         Gov.allVariants.newIfRequired room

#     for gName, gov of room.memory.governors
#       gov.tick()
#       gov.updateEdicts()
#       freq.onRareOrReload 0, =>
#         logger.info l"cleaning govs in #{room}"
#         gov.clean()

#   freq.onRare 1, =>
#     cleanMemory()


module.exports = Zone
