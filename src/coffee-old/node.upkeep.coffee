'use strict'

# CAsm = require 'casm'
Node = require 'node.core'
# Edict = require 'edicts'
# Role = require 'roles'
# procs = require 'casm.procs'
# logger = require 'logger'
# _ = require 'lodash'

# Include = CAsm.Include
# Label = CAsm.Label
# Cond = CAsm.Cond
# Op = CAsm.Op


# class Harvester extends Role
#   @makeNewVariant()

#   @selectParts: (maxCost) ->
#     [MOVE, WORK, CARRY]


# class StaticHarvester extends Harvester
#   @makeNewVariant()

#   @selectParts: (maxCost) ->
#     [MOVE, WORK, CARRY]


# class RefillSpawner extends CAsm.Task
#   @makeNewVariant()

#   @casm: new CAsm 'refill-spawner', [
#     new CAsm.Include procs.refill
#   ]

#   constructor: (source, opts) ->
#     super source, opts


# class RefillController extends CAsm.Task
#   @makeNewVariant()

#   @casm: new CAsm 'refill-controller', [
#     new Include procs.refill
#     new Op.Copy 'controllerid', 1
#     new Op.Branch label: 'refill', link: true
#   ]

#   constructor: (source, opts) ->
#     super source, opts
#     if not @params.controllerid? then throw Error 'no controller id'


# class HarvestEdict extends Edict
#   Edict.variants[@name] = @

#   @filter: (creep) ->
#     creep.role instanceof Harvester

#   Object.defineProperty @prototype, 'target',
#     enumerable: false
#     get: ->
#       if @targetCache
#         @targetCache
#       else
#         @targetCache = Game.getObjectById @targetId
#     set: (val) ->
#       @targetCache = val
#       @targetId = val.id

#   constructor: (source, opts) ->
#     super source, opts
#     { @targetId } = opts
#     Object.defineProperty @, 'targetCache',
#       enumerable: false
#       value: opts.target

#     if not @targetId
#       @targetId = @targetCache.id


# class StaticHarvestEdict extends Edict
#   Edict.variants[@name] = @

#   @filter: (creep) ->
#     creep.role instanceof Harvester

#   constructor: (opts) ->


class UpkeepNode extends Node

#   @HarvestEdict = HarvestEdict
#   @StaticHarvestEdict = StaticHarvestEdict
#   @Harvester = Harvester

#   @requiredInRoom: (room, maybeGov) ->
#     true

#   constructor: (room, opts) ->
#     super(room, opts)
#     { @harvesters = 3,
#       @staticHarvesters = off,
#     } = opts

#   tick: ->
#     super()

#   updateEdicts: ->
#     for source, i in @room.find FIND_SOURCES
#       name = 'harvest_' + source.id
#       @makeEdict name, Edict.CreateCreeps,
#         name: name
#         target: source

#     if @staticHarvesters
#       num = 0
#       @makeEdict 'createStaticHarvesters', Edict.CreateCreeps,
#         creepName: 'sHarvester'
#         role: StaticHarvester
#         number: num
#         maxWorkers: num

#     @makeEdict 'createHarvesters', Edict.CreateCreeps,
#       creepName: 'harvester'
#       priority: Edict.priority.MED
#       maxWorkers: @harvesters
#       type: Edict.type.REPEAT
#       role: Harvester
#       number: @harvesters

#     # for spawn, i in @room.find FIND_MY_SPAWNS
#     #   @makeEdict 'fillSpawner' + spawn.name, Edict.RunTask,
#     #     task: Task.Refill
#     #     taskOpts:
#     #       target: spawn.id
#     #     priority: Edict.priority.MED
#     #     maxWorkers: 1
#     #     type: Edict.type.REPEAT

#     # @makeEdict 'fillController', Edict.RunTask,
#     #   task: Task.Refill
#     #   taskOpts:
#     #     target: @room.controller.id
#     #   priority: Edict.priority.MED
#     #   maxWorkers: 1
#     #   type: Edict.type.REPEAT

#     @makeEdict 'fillController', RefillController,
#       params:
#         controllerid: @room.controller.id
#       priority: Edict.priority.MED
#       maxWorkers: 1
#       type: Edict.type.REPEAT

#     super()


module.exports = UpkeepNode

