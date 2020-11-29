'use strict'

Gov = require 'governors'
Edict = require 'edicts'
Role = require 'roles'
Task = require 'tasks'

logger = require 'logger'
_ = require 'lodash'


class Harvester extends Role
  @makeNewVariant()

  @selectParts: (maxCost) ->
    [MOVE, WORK, CARRY]


class StaticHarvester extends Harvester
  @makeNewVariant()

  @selectParts: (maxCost) ->
    [MOVE, WORK, CARRY]


class HarvestEdict extends Edict
  Edict.variants[@name] = @

  @filter: (creep) ->
    creep.role instanceof Harvester

  Object.defineProperties @prototype,
    targetCache:
      enumerable: false

    target:
      enumerable: false
      get: ->
        if @targetCache
          @targetCache
        else
          @targetCache = Game.getObjectById @targetId
      set: (val) ->
        @targetCache = val
        @targetId = val.id

  constructor: (source, opts) ->
    super source, opts
    { target: @targetCache, @targetId } = opts

    if not @targetId
      @targetId = @targetCache.id


class StaticHarvestEdict extends Edict
  Edict.variants[@name] = @

  @filter: (creep) ->
    creep.role instanceof Harvester

  constructor: (opts) ->


class UpkeepGov extends Gov
  @makeNewVariant()

  @HarvestEdict = HarvestEdict
  @StaticHarvestEdict = StaticHarvestEdict
  @Harvester = Harvester

  @requiredInRoom: (room, maybeGov) ->
    true

  constructor: (room, opts) ->
    super(room, opts)
    { @harvesters = 3,
      @staticHarvesters = off,
    } = opts

  tick: ->
    super()

  updateEdicts: ->
    for source, i in @room.find FIND_SOURCES
      name = 'harvest_' + source.id
      @makeEdict name, Edict.CreateCreeps,
        name: name
        target: source

    if @staticHarvesters
      num = 0
      @makeEdict 'createStaticHarvesters', Edict.CreateCreeps,
        creepName: 'sHarvester'
        role: StaticHarvester
        number: num
        maxWorkers: num

    @makeEdict 'createHarvesters', Edict.CreateCreeps,
      creepName: 'harvester'
      priority: Edict.priority.MED
      maxWorkers: @harvesters
      type: Edict.type.REPEAT
      role: Harvester
      number: @harvesters

    super()


module.exports = UpkeepGov
