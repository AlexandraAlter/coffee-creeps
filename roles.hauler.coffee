'use strict'

class Hauler
  constructor: (@screep) ->

  id = 1
  parts = [MOVE, WORK, CARRY]

  mem = Memory.roles.harvester = {}

  closestInefficient: (creep) ->
    source = creep.pos.findClosestByRange Game.SOURCES
    if creep.store.getFreeCapacity() > 0
      sources = creep.room.find FIND_SOURCES
      if creep.harvest sources[0] is ERR_NOT_IN_RANGE
        creep.moveTo sources[0]
    else
      if (creep.transfer Game.spawns['Spawn1'] RESOURCE_ENERGY) is ERR_NOT_IN_RANGE
        creep.moveTo Game.spawns['Spawn1']


  tick: () ->

module.exports = Hauler
