'use strict'

rooms = require 'rooms'
roles = require 'roles'
logger = require 'logger'


mem = Memory.factories or (Memory.factories = {})
if not mem.state? then mem.state = {}
if not mem.reqs? then mem.reqs = {}


class Factory
  constructor: (@name, @spawner) ->

  run: () ->
    if not @spawner.isActive() or @spawner.spawning
      return

    room = new rooms.Room @spawner.room
    creeps = room.inner.find FIND_MY_CREEPS

    missing = room.getMissingReqs()
    if missing.length > 0
      name = missing[0].name
      parts = missing[0].role.parts
      err = @spawner.spawnCreep(parts, name)
      if err isnt 0
        logger.error 'spawning creep threw', err

    return


getFactories = ->
  for name, spawn of Game.spawns
    yield new Factory name, spawn
  return


run = ->
  for factory from getFactories()
    factory.run()
  return


module.exports = { Factory, run }

