'use strict'


do ->
  Memory.loadBackoff ?= 0
  if Memory.loadBackoff > 0
    console.log "load backoff at #{Memory.loadBackoff}"
    Memory.loadBackoff--
    throw {}
backoff = () ->
  Memory.loadBackoff = 10


try
  #creeps = require 'creeps'
  #spawns = require 'spawns'
  #rooms = require 'rooms'

  #Role = require 'roles'
  #Task = require 'tasks'
  #Edict = require 'edicts'
  govs = require 'govs.all'
  #CAsm = require 'casm'

  #logger = require 'logger'
  #l = logger.fmt
  #freq = require 'freq'
catch e
  backoff()
  throw e


tick = ->
#   logger.resetIndent()
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
#     Room.cleanMemory()

#   for sName, spawn of Game.spawns
#     spawn.init()
#     spawn.tick()
#   freq.onRare 2, =>
#     StructureSpawn.cleanMemory()

#   for cName, creep of Game.creeps
#     creep.init()
#     creep.tick()
#   freq.onRare 3, =>
#     Creep.cleanMemory()


# global.tools = require 'tools'
# global.Role = Role
# global.CAsm = CAsm
# global.Task = Task
# global.Edict = Edict
# global.Gov = Gov


module.exports.loop = tick
