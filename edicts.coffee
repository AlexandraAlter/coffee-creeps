'use strict'

_ = require 'lodash'
logger = require 'logger'
u = require 'utils'


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


class Edict
  @variants: {}

  @status: status
  @type: type

  @toJSON: ->
    'class ' + @name

  @newFromMem: (@source, opts) ->
    try
      cls = @variants[opts.cls]
      edict = new cls @source, opts
      logger.trace 'reconstituted Edict', edict, indent: 2
      return edict
    catch err
      logger.error 'Edict.newFromMem failed\n', err.stack, indent: 2
      return

  @filter: (creep) -> false

  constructor: (@source, opts) ->
    { @name,
      @priority = u.priority.MED,
      @status = Edict.status.READY,
      @type = Edict.type.ONESHOT,
      @lastStart = null,
      @lastFinish = null,
      @creeps = null,
    } = opts
    throw Error('must provide a name') if not _.isString @name
    Object.defineProperty @, 'source',
      enumerable: false

  countWorkers: ->
    if typeof @creeps is 'array'
      @creeps.length
    else if typeof @creeps is 'object' or typeof @creeps is 'string'
      1
    else 0

  isAcceptingWorkers: ->
    @status is status.READY or
    (@status is status.UNDERWAY and @type is type.REPEATABLE)

  toString: ->
    "#{@constructor.name}()"

  toJSON: -> {
    cls: @constructor.name,
    @...,
  }


class Edict.CreateCreep extends Edict
  Edict.variants[@name] = @

  constructor: (source, opts) ->
    super source, opts
    {@spec} = opts

  toString: ->
    @constructor.name + "(#{@spec})"


class Edict.DestroyCreep extends Edict
  Edict.variants[@name] = @

  constructor: (@spec)

  toString: ->
    "DestroyCreep(#{@spec})"


class Edict.RunTask extends Edict
  Edict.variants[@name] = @

  constructor: (@task)

  toString: ->
    "RunTask(#{@task})"


module.exports = Edict
