'use strict'

Role = require 'roles.base'
logger = require 'logger'


class Harvester extends Role
  @id: 1
  @parts: [MOVE, WORK, CARRY]

  @fromCreep: (creep) ->
    new Harvester creep

  closestInefficient: () ->
    source = @creep.pos.findClosestByRange Game.SOURCES
    if @creep.store.getFreeCapacity() > 0
      sources = @creep.room.find FIND_SOURCES
      source = sources[0]
      err = @creep.harvest source
      if err is ERR_NOT_IN_RANGE
        @creep.moveTo source
      else if err isnt 0
        logger.error 'harvesting threw', err
    else
      err = @creep.transfer Game.spawns['Spawn1'], RESOURCE_ENERGY
      if err is ERR_NOT_IN_RANGE
        @creep.moveTo Game.spawns['Spawn1']
      else if err isnt 0
        logger.error 'transferring threw', err


  tick: ->
    @closestInefficient()


module.exports = Harvester
