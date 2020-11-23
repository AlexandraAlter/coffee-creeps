'use strict'

_ = require 'lodash'

roles = require 'roles'
governors = require 'governors'
logger = require 'logger'
u = require 'utils'


defaultReqs = (room) ->
  reqs =
    creeps:
      harvester1: roles.Harvester


Room::initFirstTime = ->
  logger.info "first time room init for #{@name}", indent: 1
  @memory = {} unless @memory?
  @memory.governors = {} unless @memory.governors?
  @memory.backoff = 0


Room::init = ->
  if @memory.backoff > 0
    @memory.backoff--
    return
  if u.onFreq u.freq.RELOAD
    @initFirstTime()
  logger.trace "room tick for #{@name}", indent: 1
  for gName, gov of @memory.governors
    @memory.governors[gName] = governors.newFromMem @, gov
  return



# class Room
#   constructor: (@inner) ->
#     Object.defineProperty this, 'mem',
#       get: ->
#         @inner.mem or (@inner.mem = {})

#   getReqs: ->
#     @mem.reqs or (@mem.reqs = defaultReqs(@inner))

#   getMissingReqs: ->
#     if @missing? then return @missing

#     reqs = @getReqs()
#     creeps = @inner.find FIND_MY_CREEPS
#     missing = []

#     for name, role of reqs.creeps
#       if _.find creeps, (c) -> c.name is name
#         continue
#       else
#         missing.push { name, role }

#     return @missing = missing


# rooms = [new Room room for room in Game.rooms]


# module.exports = { Room, rooms }
