'use strict'

Core = require 'core'
log = require 'log'
freq = require 'freq'

logger = log.getLogger 'worker'
l = log.fmt


class Worker extends Core.Backed
  Object.defineProperty @prototype, 'ref',
    get: getRef = -> @backing.id

  Object.defineProperty @prototype, 'zone',
    get: getZone = -> @backing.room.core

  constructor: (backing) ->
    super backing
    freq.onSafety =>
      throw Error 'Worker is virtual' if @constructor is Worker
    @id = backing.id

  fetchBacking: ->
    obj = Game.getObjectById @id
    throw Error "invalid id #{@id} in #{@}" if not obj?
    return obj


class Worker.Task extends Core


module.exports = Worker
