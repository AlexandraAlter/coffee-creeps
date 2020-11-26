'use strict'

Job = require 'jobs'
Base = require 'base'

u = require 'utils'
logger = require 'logger'

_ = require 'lodash'


status =
  READY: 'ready'
  UNDERWAY: 'underway'
  DONE: 'done'
  FAILED: 'failed'
  REMOVING: 'removing'

type =
  ONESHOT: 'oneshot'
  REPEATABLE: 'repeatable'
  MULTIPLE: 'multiple'


class Edict extends Base
  @variants: {}

  @makeNewVariant: ->
    Edict.variants[@name] = @
    Edict[@name] = @


  @status: status
  @type: type


  @newFromMem: (source, opts) ->
    try
      cls = @variants[opts.cls]
      edict = new cls source, opts
      logger.trace "reconstituted #{edict}"
      return edict
    catch err
      logger.error "Edict.newFromMem failed\n#{err.stack}"
      return


  @filter: (creep) -> false


  constructor: (@source, opts) ->
    super()
    { @name,
      @priority = u.priority.MED,
      @status = status.READY,
      @type = type.ONESHOT,
      @lastStart = null,
      @lastFinish = null,
      @creeps = [],
    } = opts
    throw Error('must provide a name') if not _.isString @name
    Object.defineProperty @, 'source', enumerable: false


  countWorkers: ->
    if typeof @creeps is 'array'
      @creeps.length
    else if typeof @creeps is 'object' or typeof @creeps is 'string'
      1
    else 0


  needsWorkers: ->
    @status is status.READY


  isAcceptingWorkers: ->
    @status is status.READY or
    (@status is status.UNDERWAY and @type is type.REPEATABLE)


  assignTo: (creep) ->
    logger.trace "assigning #{@} to #{creep}"
    @creeps.push creep.name
    @lastStart = Game.time
    # TODO do we need the source?
    creep.job = new Job edict: @ source: @source


  removeFrom: (creep) ->
    _.pull @creeps, creep.name
    @lastFinish = Game.time
    if @countWorkers() is 0
      if @type is type.ONESHOT
        @status = status.DONE
      else
        @status = status.READY


class Edict.CreateCreep extends Edict
  @makeNewVariant()


  constructor: (source, opts) ->
    super source, opts
    {@spec} = opts


class Edict.DestroyCreep extends Edict
  @makeNewVariant()


  constructor: (@spec)


class Edict.RunTask extends Edict
  @makeNewVariant()


  constructor: (@task)


module.exports = Edict
