'use strict'

Base = require 'base'
Role = require 'roles'

logger = require 'logger'
freq = require 'freq'

_ = require 'lodash'


status =
  READY: 'ready'
  UNDERWAY: 'underway'
  DONE: 'done'
  FAILED: 'failed'
  REMOVING: 'removing'

type =
  # one worker only, remove once done
  ONESHOT: 'oneshot'
  # keep once done
  REPEAT: 'repeatable'


priority =
  V_LOW: 1
  LOW: 2
  MED: 3
  HIGH: 4
  V_HIGH: 5
  CRIT: 6
  XTRM: 7


class Edict extends Base
  @variants: {}

  @makeNewVariant: ->
    Edict.variants[@name] = @
    Edict[@name] = @

  @status: status
  @type: type
  @priority: priority
  
  @newFromRef: (ref) ->
    [rName, gName, eName] = ref.split ':'
    edict = Memory.rooms[rName].governors[gName].edicts[eName]
    logger.trace "referenced #{edict}"
    return edict

  @newFromMem: (source, opts) ->
    cls = @variants[opts.cls]
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
    "[#{@cls} #{@status} #{@type} " +
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


class Edict.SpawnerEdict extends Edict
  @filter: (worker) -> true

  constructor: (spawner, opts) ->
    super spawner, opts
    {} = opts


class Edict.CreateCreeps extends Edict.SpawnerEdict
  @makeNewVariant()

  constructor: (spawner, opts) ->
    super spawner, opts
    {@role, @creepName, @number, @creeps = []} = opts
    if typeof @role is 'string'
      @role = Role.clsFromMem @role

  update: ->
    @maxWorkers = @number - @creeps.length
    for cName in @creeps
      if not Game.creeps[cName]
        _.pull @creeps, cName
    super()

  complete: (spawner) ->
    super spawner
    @creeps.push spawner.spawning.name

  toString: ->
    rName = if @role? then @role.name else null
    super().slice(0, -1) + " #{rName}*#{@number}=[#{@creeps}]]"


class Edict.DestroyCreeps extends Edict
  @makeNewVariant()

  constructor: (source, opts) ->
    super source, opts
    {@role, @number} = opts


class Edict.RunTask extends Edict
  @makeNewVariant()

  constructor: (@task)


module.exports = Edict
