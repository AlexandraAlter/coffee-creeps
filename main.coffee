'use strict'

# hotpatching
creeps = require 'creeps'
rooms = require 'rooms'

roles = require 'roles'
tasks = require 'tasks'
spawns = require 'spawns'
Gov = require 'governors.all'
creeps = require 'creeps'
logger = require 'logger'
u = require 'utils'


# ticks:
# every:
#   core functionality
# :
#   governor


tick = ->
  logger.resetIndent()
  logger.trace 'beginning tick'
  for rName, room of Game.rooms
    room.init()

    if (u.onFreq u.freq.RARELY) or (u.onFreq u.freq.RELOAD)
      logger.info "refreshing govs in #{room}"
      logger.withIndent =>
        Gov.allVariants.delIfRequired room
        Gov.allVariants.newIfRequired room

    for gName, gov of room.memory.governors
      gov.tick()
      gov.updateEdicts()

  for rName, room of Game.spawns
    ""

  for cName, creep of Game.creeps
    creep.init()
    creep.tick()

  for rName, room of Game.structures
    ""


module.exports.loop = tick
