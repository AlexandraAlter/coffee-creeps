'use strict'

log = require 'log'
Role = require 'role'
Worker = require 'worker'

logger = log.getLogger 'worker.spawn'


class SpawnWorker extends Worker
  @backingCls = StructureSpawn

  @defineMemory 'memPath'

  Object.defineProperty @prototype, 'ref',
    get: getRef = -> @backing.name

  constructor: (backing) ->
    super backing
    @name = backing.name
    @memPath = ['spawns', @name]

  tick: ->

  spawn: (role) ->
    throw Error 'requires arg role' if not role?
    if role.prototype instanceof Role
      role = role.fromSpawner @
    else if role not instanceof Role
      throw Error 'invalid role'


module.exports = SpawnWorker
