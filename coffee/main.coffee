'use strict'


do ->
  Memory.loadBackoff ?= 0
  if Memory.loadBackoff > 0
    console.log "load backoff at #{Memory.loadBackoff}"
    Memory.loadBackoff--
    throw {}
backoff = () -> Memory.loadBackoff = 10


try
  log = require 'log'
  freq = require 'freq'
  workers = require 'workers'
  Zone = require 'zone'
  Sys = require 'sys'

  logger = log.getLogger 'main'
  l = log.fmt
catch e
  backoff()
  throw e


do setGlobals = ->
  global.log ?= log
  global.freq ?= freq
  global.tools ?= require 'tools'
  global.report ?= require 'report'

  global.workers ?= workers
  global.nodes ?= require 'nodes'
  global.cortexes ?= require 'cortexes'
  global.Zone ?= Zone
  global.Brain ?= require 'brain'

  global.Sys ?= Sys


tick = ->
  freq.onReload =>
    workers.linkAllProtos()
    Zone.linkProto()
    Sys.reload()
  Sys.clean()
  Sys.linkGame()


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
