'use strict'

Base = require 'base'
logger = require 'logger'
l = logger.fmt
freq = require 'freq'


class Res
  constructor: (@name, opts) ->
    opts = opts or {}
    { @adv = null,
      @imm = false,
      @skipTask = false,
      @abort = false,
      @unimpl = false,
    } = opts

  toString: ->
    "[Res #{@name} adv=#{@adv} imm=#{@imm} 
    skipTask=#{@skipTask} abort=#{@abort} unimpl=#{@unimpl}]"

  Again: new Res 'again', adv: 0
  AgainImm: new Res 'again', adv: 0, imm: true

  Next: new Res 'next', adv: 1
  NextImm: new Res 'next_imm', adv: 1, imm: true

  Skip: (count) -> new Res 'skip', adv: count + 1
  Skip1: Res.Skip 1
  SkipImml: (count) -> new Res 'skip', adv: count + 1, imm: true
  SkipImml1: Res.SkipImml 1

  SkipTask: (count) -> new Res 'skip', skipTask: true
  SkipTaskImm: (count) -> new Res 'skip', skipTask: true, imm: true

  Abort: new Res 'abort', abort: true

  Unimpl: new Res 'unimpl', unimpl: true


class TaskState
  @toString: ->
    "[class #{@name}]"

  @newFromMem: (creep, vals) ->
    state = new TaskState creep, vals
    logger.trace l"reconstituted #{state}"
    return state

  constructor: (@creep, vals) ->
    Object.assign @, vals
    Object.defineProperty @, 'creep',
      enumerable: false
    # Object.defineProperty @, 'blocked',
    #   enumerable: false
    #   writable: true
    #   value: false
    # Object.defineProperty @, 'continuing',
    #   enumerable: false
    #   writable: true
    #   value: false
    # Object.defineProperty @, 'stageOffset',
    #   enumerable: false
    #   writable: true
    @stage = 0 if not @stage?

  # init: ->
    # @blocked = false
    # @continuing = false
    # @stageOffset = null

  advance: (count) -> @stage += count

  # handleRes: (res) ->
  #   if res is Res.AGAIN
  #     @blocked = true
  #     0
  #   else if res is Res.NEXT
  #     @blocked = true
  #     @changeStage 1
  #   else if res is Res.NEXT_IMM
  #     @continuing = true
  #     @changeStage 1
  #   else if res > 0
  #     @continuing = true
  #     @changeStage res
  #     return res
  #   else if res is Res.SKIP_SUBTASK
  #     throw Error "SKIP_SUBTASK isn't implemented yet"
  #   else if res is Res.SKIP_SUBTASK_IMM
  #     throw Error "SKIP_SUBTASK_IMM isn't implemented yet"
  #   else if res is Res.UNIMPL
  #     throw Error "hit unimplemented method for #{@}"
  #   else
  #     throw Error "unknown task result #{res} for #{@}"

  toString: ->
    "[#{@constructor.name} c=#{@creep} s=#{@stage}]"


class Task extends Base
  @variants = {}

  @makeNewVariant: ->
    Task.variants[@name] = @
    Task[@name] = @

  @Res: Res
  @TaskState: TaskState

  @subtasks: null
  @stages: 1

  @stagesFromSubtasks: ->
    ownTasks = 0
    _.sum(
      for sub in @subtasks
        if typeof sub is 'function'
          1
        else if sub instanceof Task
          sub.stages
        else
          throw Error "invalid type in subtasks: #{sub}"
    )

  @clsFromMem: (str) ->
    cls = @variants[str]
    throw 'invalid class' if not cls?
    return cls

  @newFromMem: (opts) ->
    cls = @variants[opts.cls]
    task = new cls opts
    logger.trace l"reconstituted #{task}"
    return task

  Object.defineProperties @prototype,
    stages:
      get: -> @constructor.stages
      enumerable: false
    subtasks:
      get: -> @constructor.subtasks
      enumerable: false

  constructor: (opts) ->
    super()

  newState: (creep) -> new TaskState creep, {}

  init: (state) ->

  getSubtaskIndexes: (stage) ->
    counter = 0

    for task, index in @subtasks
      isFunc = typeof task is 'function'
      if stage <= counter
        return [index, counter]
      else
        counter += if isFunc then 1 else task.stages

    return [null, null]

  doSubTask: (state, stage, task, offset) ->
    res = null

    if not task
      throw Error "could not find task in #{@}.#{stage} with #{state}"
    else if typeof task is 'function'
      res = task.call @, state
      logger.trace l"#{@}.#{stage} on #{state} completed with #{res}"
    else if task instanceof Task
      res = task.do state, offset
    else
      throw Error "unknown type of task #{task}"

    return res

  doWork: (state, stage) ->
    logger.info l"#{@}.#{stage} running on #{state}"
    return Res.Unimpl

  do: (state, offset = 0) ->
    infCounter = 0
    @init state
    loop
      stage = state.stage - offset
      res = null

      infCounter++
      if infCounter > 5
        throw Error "probable infinite loop in #{@} with #{state}"
      if Game.cpu.getUsed() > Game.cpu.tickLimit / 2
        throw Error "high cpu emergency break"

      if stage >= @stages
        throw Error "extended past last stage in #{@}.#{stage} with #{state}"
      else if @subtasks isnt null
        [subIndex, subOffset] = @getSubtaskIndexes stage
        subtask = @subtasks[subIndex]
        res = @doSubTask state, stage, subtask, subOffset
      else
        res = @doWork state, stage

      if not res instanceof Res
        throw Error "no result returned in #{@} with #{state}"

      else if res.unimpl
        throw Error "unimplemented stage in #{@} with #{state}"

      else if res.skipTask
        # skip to the end of the task
        stageDiff = @stages - stage
        state.advance stageDiff

      else if res.adv isnt null
        nextStage = stage + res.adv
        [nextIndex, nextOffset] = @getSubtaskIndexes nextStage
        # do not advance past the end of this task
        if nextStage > @stages
          throw Error "advanced past end in #{@}.#{stage} with #{state}"
        # do not advance over the bounds of a subtask
        else if subIndex and (nextIndex - subIndex > 1)
          throw Error "bad skip in #{@}.#{stage} with #{state}"
        # if we're advancing to the end of this task, return
        # let the caller do the increment
        else if nextStage is @stages
          return res
        else
          state.advance res.adv

      else
        throw Error "result did not advance in #{@} with #{state}"

      if res.imm
        continue
      else
        return Res.Again
    throw Error "reached an unreachable statement in #{@} with #{state}"


class Task.Move extends Task
  @makeNewVariant()

  constructor: (opts) ->
    super opts
    if opts?
      { @target, @idName = 'target', @cacheName = 'targetCache' } = opts

  init: (state) ->
    if @target?
      state[@idName] = @target
    if not state[@idName]?
      throw Error "#{@} could not find #{@idName} in #{state}"
    if not state[@cacheName]?
      Object.defineProperty state, @cacheName,
        value: Game.getObjectById state[@idName]
        enumerable: false

  doWork: (state, stage) ->
    super()
    logger.debug "Move"
    res = state.creep.moveTo state[@cacheName]
    if res isnt OK
      logger.warn l"#{state.creep} failed to move with #{res}"
    if state.creep.pos.getRangeTo state.target <= 1
      return Res.Next
    else
      return Res.Again


class Task.GetEnergy extends Task
  @makeNewVariant()

  @subtasks: [
    (state) ->
      logger.debug "GetEnergy.0"
      source = state.creep.pos.findClosestByRange FIND_SOURCES_ACTIVE
      state.sourceId = source.id
      state.sourceCache = source
      return Res.NextImm
    new Task.Move
      idName: 'sourceId'
      cacheName: 'sourceCache'
    (state) ->
      logger.debug "GetEnergy.2"
      res = state.creep.harvest state.target
      if res isnt OK
        logger.warn l"#{state.creep} failed to harvest with #{res}"
      if state.creep.store.getFreeCapacity() is 0
        return Res.Next
      else
        return Res.Again
  ]
  @stages: do => @stagesFromSubtasks()

  init: (state) ->
    if not state.targetCache?
      Object.defineProperty state, 'targetCache',
        value: Game.getObjectById state.targetId
        enumerable: false


class Task.Refill extends Task
  @makeNewVariant()

  @subtasks: [
    new Task.GetEnergy
  ]
  @stages: do => @stagesFromSubtasks()

  init: (state) ->
    if not state.targetCache?
      Object.defineProperty state, 'targetCache',
        value: Game.getObjectById state.targetId
        enumerable: false


module.exports = Task
