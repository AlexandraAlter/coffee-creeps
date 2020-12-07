'use strict'

Worker = require 'worker.core'


class SpawnWorker extends Worker
  @backingCls = StructureSpawn
  @defineMemory 'memPath'

  Object.defineProperty @prototype, 'ref',
    get: getRef = -> @backing.name

  constructor: (backing) ->
    super backing
    @name = backing.name
    @memPath = ['spawns', @name]


module.exports = SpawnWorker
