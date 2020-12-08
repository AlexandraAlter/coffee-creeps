'use strict'

Core = require 'core'
Cortex = require 'cortex'
Brain = require 'brain'
Zone = require 'zone'

Worker = require 'worker'
robots = require 'worker.robots'
structs = require 'worker.structs'
SpawnWorker = require 'worker.spawn'


class SysCls extends Core
  @defineMemory ['sys']

  Object.defineProperty @prototype, 'sys',
    get: getSys = -> @

  constructor: ->
    super()
    @workers = null
    @zones = null
    @brain = null

  toString: -> '[Sys]'

  modules: {
    upkeep: require 'sys.upkeep'
    expansion: require 'sys.expansion'
    war: require 'sys.war'
  }
  Object.assign(@::, @::modules)

  workerTypes: ->
    yield SpawnWorker
    for name, w of robots
      yield w
    for name, w of structs
      yield w

  typesOf: (superType) ->
    for mName, mod of @modules
      for oName, o of mod
        yield o if (o::) instanceof superType

  cortexTypes: -> @typesOf Cortex
  nodeTypes: -> @typesOf Node

  iterChildren: ->
    if @workers?
      for worker in @workers
        yield worker
    if @zones?
      for zone in @zones
        yield zone
    yield @brain

  linkAll: ->
    for w from @workerTypes()
      w.linkProto()

  clean: ->
    super()

  reload: ->
    @backoff.withErrRecur =>
      @brain = new Brain
      @workers = [].concat(
        Worker.from creep for name, creep of Game.creeps
        Worker.from struct for name, struct of Game.structures
      )
      @zones = _.flatten(Zone.from room for name, room of Game.rooms)
      super()


Sys = new SysCls

module.exports = Sys
