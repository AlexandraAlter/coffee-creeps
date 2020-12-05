'use strict'

base = require 'base'
freq = require 'freq'
log = require 'log'

logger = log.getLogger 'govs'
l = log.fmt


s = {}
class Status extends base.Pretty
  constructor: (@name) -> super()

s.READY    = new Status 'ready'
s.UNDERWAY = new Status 'underway'
s.DONE     = new Status 'done'
s.FAILED   = new Status 'failed'
s.REMOVING = new Status 'removing'


t = {}
class Type extends base.Pretty
  constructor: (@name) -> super()

t.ONESHOT = new Type 'oneshot'
t.REPEAT  = new Type 'repeat'


p = {}
class Priority extends base.Pretty
  constructor: (@value) -> super()

p.V_LOW  = new Priority 1
p.LOW    = new Priority 2
p.MED    = new Priority 3
p.HIGH   = new Priority 4
p.V_HIGH = new Priority 5
p.CRIT   = new Priority 6
p.XTRM   = new Priority 7


class Edict extends base.Reconst
  @variants: {}

  @clsFromMem: (str) ->
    cls = @variants[str]
    throw 'invalid class' if not cls?
    return cls

  @newFromRef: (ref) ->
    [rName, gName, eName] = ref.split ':'
    edict = Memory.rooms[rName].governors[gName].edicts[eName]
    logger.trace "referenced #{edict}"
    return edict

  @newFromMem: (source, opts) ->
    cls = @variants[opts.cls]
    if not cls?
      logger.error 'trashed bad edict'
      return
    edict = new cls source, opts
    logger.trace "reconstituted #{edict}"
    return edict

  @filter: (worker) -> false

  constructor: (@source, opts) ->
    super()
    { # setup
      @name,
      @priority = priority.MED,
      @type = type.ONESHOT,
      @maxWorkers = 1,
      # state
      @status = status.READY,
      @lastStart = null,
      @lastFinish = null,
      @curWorkers = 0,
      @completions = 0,
      @failures = 0,
    } = opts
    freq.onSafety =>
      throw Error('must provide a name') if not _.isString @name
      @curWorkers = 0 if typeof @curWorkers isnt 'number'
      @completions = 0 if typeof @completions isnt 'number'
      @failures = 0 if typeof @failures isnt 'number'
    Object.defineProperty @, 'source', enumerable: false

  toString: ->
    "[#{@cls}@#{@name} #{@status} #{@type} " +
      "#{@completions}+#{@curWorkers}/#{@maxWorkers}]"

  toRef: ->
    "#{@source.room.name}:#{@source.cls}:#{@name}"

  # predicates

  isReady: -> @status is status.READY
  isUnderway: -> @status is status.UNDERWAY
  isDone: -> @status is status.DONE
  isFailed: -> @status is status.FAILED
  isRemoving: -> @status is status.REMOVING

  isRepeatable: -> @type is type.REPEAT

  needsWorkers: -> @isReady()
  isAcceptingWorkers: -> @isReady() or (@isUnderway() and @isRepeatable())

  # functionality

  update: ->
    if @type is type.REPEAT
      if @maxWorkers <= 0
        @status = status.DONE
      else if @curWorkers >= @maxWorkers
        @status = status.UNDERWAY
      else
        @status = status.READY

    if @type is type.ONESHOT
      if @completions >= @maxWorkers
        @status = status.DONE
      else if @curWorkers + @completions >= @maxWorkers
        @status = status.UNDERWAY
      else if @curWorkers + @completions < @maxWorkers
        @status = status.READY
      else
        @status = status.FAILED

    return @

  _assignWorker: (worker) ->
    logger.trace "assigning #{@} to #{worker}"
    @curWorkers++
    @update()

  _removeWorker: (worker) ->
    logger.trace "removing #{@} from #{worker}"
    @curWorkers--
    @update()

  start: (worker) ->
    @lastStart = Game.time
    @_assignWorker worker

  complete: (worker) ->
    @completions++
    @lastFinish = Game.time
    @_removeWorker worker

  fail: (worker) ->
    @failures++
    @_removeWorker worker

  tick: ->

  clean: ->


class Gov extends base.Reconst
  @variants: {}

  @allVariants:

    newIfRequired: (room) =>
      logger.trace "adding govs in #{room}"
      for gName, govCls of Gov.variants
        curGov = room.memory.governors[govCls.name]
        if not curGov? and govCls.requiredInRoom room, curGov
          logger.info "attaching #{govCls}"
          room.attachGov(govCls)

    delIfRequired: (room) =>
      logger.trace "deleting govs in #{room}"
      for gName, govCls of Gov.variants
        curGov = room.memory.governors[govCls.name]
        if curGov? and not govCls.requiredInRoom room, curGov
          logger.info "deleting #{govCls}"
          room.detatchGov(govCls)

  # returns true if the given room requires this governor
  @requiredInRoom: (room, maybeGov) ->
    false

  @newFromMem: (room, opts) ->
    cls = @variants[opts.cls]
    gov = new cls room, opts
    logger.trace "reconstituted #{gov}"
    return gov

  constructor: (@room, opts) ->
    super()

    Object.defineProperty @, 'room', enumerable: false

    {@edicts = {}, @backoff = 0} = opts
    Object.defineProperty @, 'backedOff',
      enumerable: false
      value: false

    for eName, e of @edicts
      @edicts[eName] = Edict.newFromMem @, e

  withBackoff: (func) ->
    if @backedOff
      return
    if @backoff > 0
      @backoff--
      @backedOff = true
      return
    try
      return func.call @
    catch err
      @backoff = 10
      logger.info "gov backoff for #{@cls}"
      throw err

  initFirstTime: ->

  tick: ->
    @withBackoff ->
      logger.trace "gov tick for #{@cls}"
      freq.onReload =>
        @initFirstTime()
      return

  makeEdict: (name, edictCls, opts) ->
    if @edicts[name] and (@edicts[name] instanceof edictCls)
      for k, v of opts
        @edicts[name][k] = v
      @edicts[name].name = name
    else
      @edicts[name] = new edictCls @, {name: name, opts...}

  updateEdicts: ->
    for eName, edict of @edicts
      edict.update()

  assignEdicts: ->
    @withBackoff ->
      logger.trace "assigning edicts for #{@}"
      for edict of @edicts
        logger.trace "considering #{edict}", indent: 1
        assigned = false
        for creep of Game.creeps
          if false
            logger.withIndent =>
              edict.assignTo creep
            assigned = true
            break
        if not assigned
          logger.trace "could not assign #{edict}", indent: 2

  clean: ->
    for eName, edict of @edicts
      edict.clean()

  toString: ->
    edictNum = Object.keys(@edicts).length
    "[#{@cls} r=#{@room.name} e=#{edictNum}]"


module.exports = {
  Status, s, s...
  Type, t, t...
  Priority, p, p...
  Gov
  Edict
}
