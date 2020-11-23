'use strict'

# hotpatching
creeps = require 'creeps'
rooms = require 'rooms'

roles = require 'roles'
tasks = require 'tasks'
spawns = require 'spawns'
governors = require 'governors'
creeps = require 'creeps'
logger = require 'logger'
u = require 'utils'


# ticks:
# every:
#   core functionality
# :
#   governor


tick = ->
  logger.trace 'beginning tick'
  for rName, room of Game.rooms
    room.init()

    if u.onFreq u.freq.RARELY
      governors.delIfRequired room
      governors.newIfRequired room

    for gName, gov of room.memory.governors
      gov.tick()
      gov.updateEdicts()

  for cName, creep of Game.creeps
    creep.init()

  for rName, room of Game.spawns
    ""

  for rName, room of Game.structures
    ""


module.exports = { loop: tick }

