'use strict'

_ = require 'lodash'
log = require 'log'
Core = require 'core'
Backoff = require 'backoff'
freq = require 'freq'

logger = log.getLogger 'room'
l = log.fmt


class Zone extends Core.Backed
  @backingCls = Room

  constructor: (backing) ->
    super backing
    @name = backing.name
    @nodes = []
    @workers = []

  toString: -> super()[...-1] + " #{@name}]"

  fetchBacking: -> Game.rooms[@name]

  addNode: (node) -> @nodes.append node
  remNode: (node) -> _.pull @nodes, node


# Room::attachGov = (govCls) ->
#   @memory.governors[govCls.name] = new govCls @, {}


# Room::detatchGov = (govCls) ->
#   delete @memory.governors[govCls.name]


# Room::initFirstTime = ->
#   logger.info "initFirstTime for #{@}"
#   @memory = {} unless @memory?
#   @memory.governors = {} unless @memory.governors?
#   @memory.backoff = 0


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
