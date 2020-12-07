'use strict'

Worker = require 'worker.core'


class RobotWorker extends Worker
  @backingCls = Creep

  @defineMemory 'memPath'

  constructor: (backing) ->
    super backing
    @name = backing.name
    @memPath = ['creeps', @name]

  fetchBacking: -> Game.creeps[@name]

  # overrides Core.Backed::exists
  exists: -> @name of Game.creeps


class PowerRobotWorker extends RobotWorker
  @backingCls = PowerCreep
  @defineMemory 'creeps'


module.exports = {
  RobotWorker
  PowerRobotWorker
}
