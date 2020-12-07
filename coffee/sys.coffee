'use strict'

Core = require 'core'
Brain = require 'brain'
workers = require 'workers'
Zone = require 'zone'


class SysCls extends Core
  constructor: ->
    super()
    @workers = null
    @zones = null
    @brain = new Brain @

  toString: -> '[Sys]'

  iterChildren: ->
    if @workers?
      for worker in @workers
        yield worker
    if @zones?
      for zone in @zones
        yield zone

  clean: ->
    super()
    @brain.clean()

  reload: ->
    @workers = [].concat(
      workers.Worker.from creep for name, creep of Game.creeps
      workers.Worker.from struct for name, struct of Game.structures
    )
    @zones = _.flatten(Zone.from room for name, room of Game.rooms)


Sys = new SysCls

module.exports = Sys
