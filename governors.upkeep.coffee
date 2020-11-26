'use strict'

Gov = require 'governors'
Edict = require 'edicts'
Role = require 'roles'

logger = require 'logger'

_ = require 'lodash'


class HarvestEdict extends Edict
  Edict.variants[@name] = @

  @filter: (creep) ->
    true

  constructor: (source, opts) ->
    super source, opts
    { @target } = opts


class StaticHarvestEdict extends Edict
  Edict.variants[@name] = @

  @filter: (creep) ->
    true

  constructor: (opts) ->


class Harvester extends Role
  Role.variants[@name] = @


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

  updateEdicts: ->
    @edicts = {}
    for source, i in @room.find FIND_SOURCES
      name = 'harvest ' + i
      if not @edicts[name]?
        @edicts[name] =
          new HarvestEdict @,
            name: name
            target: source
    for i in [1...@harvesters]
      name = 'new harvester ' + i
      @edicts[name] =
        new Edict.CreateCreep @,
          name: name
          spec: ''


module.exports = UpkeepGov
