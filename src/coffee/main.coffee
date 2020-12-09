'use strict'


do ->
  Memory.loadBackoff ?= 0
  if Memory.loadBackoff > 0
    console.log "load backoff at #{Memory.loadBackoff}"
    Memory.loadBackoff--
    throw {}
backoff = () -> Memory.loadBackoff = Memory.defaultBackoff ? 10


try
  do setGlobals = ->
    global.log ?= require 'log'
    global.freq ?= require 'freq'
    global.Backoff ?= require 'backoff'
    global.Zone ?= require 'zone'
    global.Brain ?= require 'brain'
    global.Sys ?= require 'sys'

    global.tools ?= require 'tools'
    global.report ?= require 'report'

  logger = log.getLogger 'main'
  l = log.fmt

catch e
  backoff()
  throw e


tick = ->
  freq.onReload =>
    logger.info 'starting reload'

    try
      Sys.linkAll()
      Sys.reload()
    catch err
      throw '' if err instanceof Backoff.Error
      throw err

    freq.reloadDone()
    logger.info 'finished reload'

  Sys.backoff.with =>
    Sys.clean()
    Sys.linkGame()
    Sys.refresh()
    Sys.tick()

  # for room of @rooms
  #   room.reset()
  #   room.tick()

#   for rName, room of Game.rooms
#     room.init()

#     freq.onRareOrReload 0, =>
#       logger.info l"refreshing govs in #{room}"
#       Gov.allVariants.delIfRequired room
#       Gov.allVariants.newIfRequired room

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


module.exports.loop = tick
