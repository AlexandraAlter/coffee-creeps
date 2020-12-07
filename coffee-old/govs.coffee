'use strict'

Core = require 'core'
Backoff = require 'backoff'
freq = require 'freq'
log = require 'log'

logger = log.getLogger 'govs'
l = log.fmt


s = {}
class Status
  @toString: -> "[class #{@name}]"
  constructor: (@name) -
  toJSON: -> @name
  toString: -> "[#{@constructor.name} #{@name}]"

s.READY    = new Status 'ready'
s.UNDERWAY = new Status 'underway'
s.DONE     = new Status 'done'
s.FAILED   = new Status 'failed'
s.REMOVING = new Status 'removing'

do -> s[o.name] = o for n, o of s


t = {}
class Type
  @toString: -> "[class #{@name}]"
  constructor: (@name) ->
  toJSON: -> @name
  toString: -> "[#{@constructor.name} #{@name}]"

t.ONESHOT = new Type 'oneshot'
t.REPEAT  = new Type 'repeat'

do -> t[o.name] = o for n, o of t


p = {}
class Priority
  @toString: -> "[class #{@name}]"
  constructor: (@value, @name) ->
  toJSON: -> @value
  toString: -> "[#{@constructor.name} #{@name}]"

p.V_LOW  = new Priority 1, 'very low'
p.LOW    = new Priority 2, 'low'
p.MED    = new Priority 3, 'medium'
p.HIGH   = new Priority 4, 'high'
p.V_HIGH = new Priority 5, 'very high'
p.CRIT   = new Priority 6, 'critical'
p.XTRM   = new Priority 7, 'extreme'

do -> p[o.value] = o for n, o of p


class Task extends Core
  @statuses = s
  @types = t
  @priorities = p

  @parseRef: (ref) ->
    parts = ref.split ':'
    throw Error "invalid reference #{ref}" if parts.length isnt 3
    return parts

  Object.defineProperty @prototype, 'memory',
    get: ->
      return @_memory if @_memory?
      Memory.tasks ?= {}
      return @_memory = Memory.tasks[@toRef] ?= @cleanMem {}
    set: (val) -> @_memory = Memory.tasks[@toRef] = val

  constructor: (@gov, opts) ->
    super()
    { @name, @priority = p.MED, @type = t.ONESHOT, @maxWorkers = 1 } = opts
    @state = @getState()
    freq.onSafety =>
      throw Error('invalid governor') if not @gov instanceof Gov
      throw Error('must provide a name') if not _.isString @name

  cleanMem: (mem) ->
    mem ?= {}
    mem.ref = @toRef()
    mem.status ?= s.READY
    mem.lastStart ?= null
    mem.lastFinish ?= null
    mem.workers = 0 if not _.isNumber mem.workers
    mem.succCount = 0 if not _.isNumber mem.succCount
    mem.failCount = 0 if not _.isNumber mem.failCount
    mem

  reset: ->
    delete @_memory

  toString: ->
    super()[...-1] + "@#{@name} #{@status} #{@type} " +
      "#{@completions}+#{@curWorkers}/#{@maxWorkers}]"

  toRef: ->
    "#{@gov.room.name}:#{@gov.constructor.name}:#{@name}"

  filter: (worker) -> false

  # predicates

  isReady: -> @memory.status is s.READY
  isUnderway: -> @memory.status is s.UNDERWAY
  isDone: -> @memory.status is s.DONE
  isFailed: -> @memory.status is s.FAILED
  isRemoving: -> @memory.status is s.REMOVING

  isRepeatable: -> @memory.type is t.REPEAT

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


class Gov extends Core
  @filter: (room, maybeGov) -> false

  @defineMemory 'govs'

  constructor: (@room, opts) ->
    super()

    {@tasks = {}} = opts
    @backoff = new Backoff @

    # for eName, e of @tasks
    #   @tasks[eName] = Task.newFromMem @, e

  cleanMem: (mem) ->
    mem ?= {}
    mem.ref = @toRef()
    mem.taskRefs ?= []
    mem

  reset: ->
    super()
    @backoff.reset()

  initFirstTime: ->

  tick: ->
    @withBackoff ->
      logger.trace "gov tick for #{@cls}"
      freq.onReload =>
        @initFirstTime()
      return

  makeTask: (name, taskCls, opts) ->
    if @tasks[name] and (@tasks[name] instanceof taskCls)
      for k, v of opts
        @tasks[name][k] = v
      @tasks[name].name = name
    else
      @tasks[name] = new taskCls @, {name: name, opts...}

  updateTasks: ->
    for eName, task of @tasks
      task.update()

  assignTasks: ->
    @withBackoff ->
      logger.trace "assigning tasks for #{@}"
      for task of @tasks
        logger.trace "considering #{task}", indent: 1
        assigned = false
        for creep of Game.creeps
          if false
            logger.withIndent =>
              task.assignTo creep
            assigned = true
            break
        if not assigned
          logger.trace "could not assign #{task}", indent: 2

  clean: ->
    for eName, task of @tasks
      task.clean()

  toString: ->
    tasks = @memory.taskRefs.length
    super()[...-1] + " r=#{@room.name} t#=#{tasks}]"

  toRef: ->
    "#{@room.name}:#{@constructor.name}"


class GovRepo extends Core
  constructor: ->
    super()
    @govs = []

  reset: ->
    for gov in @govs
      gov.reset()

  link: (game) ->
    Object.defineProperties game, 'govs',
      get: => @govs


temp =
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


module.exports = {
  Status, s, s...
  Type, t, t...
  Priority, p, p...
  Task
  Gov
  GovRepo
}
