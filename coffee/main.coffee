'use strict'

# hotpatching
require 'creeps'
require 'spawns'
require 'rooms'

Role = require 'roles'
Task = require 'tasks'
Edict = require 'edicts'
Gov = require 'governors.all'

logger = require 'logger'
l = logger.fmt
freq = require 'freq'


tick = ->
  logger.resetIndent()
  for rName, room of Game.rooms
    room.init()

    freq.onRareOrReload 0, =>
      logger.info l"refreshing govs in #{room}"
      logger.withIndent =>
        Gov.allVariants.delIfRequired room
        Gov.allVariants.newIfRequired room

    for gName, gov of room.memory.governors
      gov.tick()
      gov.updateEdicts()
  freq.onRare 1, =>
    Room.cleanMemory()

  for sName, spawn of Game.spawns
    spawn.init()
    spawn.tick()
  freq.onRare 2, =>
    StructureSpawn.cleanMemory()

  for cName, creep of Game.creeps
    creep.init()
    creep.tick()
  freq.onRare 3, =>
    Creep.cleanMemory()

  freq.onDebug =>
    tools = require 'tools'
    for n, t of tools
      Game[n] = t
    Game.Role = Role
    Game.Task = Task
    Game.Edict = Edict
    Game.Gov = Gov


module.exports.loop = tick
