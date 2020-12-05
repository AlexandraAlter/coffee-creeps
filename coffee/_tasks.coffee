'use strict'

Base = require 'base'
CAsm = require 'casm'
Op = CAsm.Op
Cond = CAsm.Cond
Label = CAsm.Label
logger = require 'logger'
l = logger.fmt
freq = require 'freq'


class Res extends Base
  constructor: (@name, opts) ->
    super()
    opts = opts or {}
    { @adv = null,
      @imm = false,
      @skipTask = false,
      @abort = false,
      @unimpl = false,
    } = opts

  isValid: ->
    if @unimpl
      throw Error 'unimplemented stage'
    freq.onSafety =>
      return (@adv isnt null) or (@skipTask isnt false) or (@abort isnt false)
    return true

  isValidToplevel: ->
    @isValid() and (@adv isnt null) and (@imm is false) and
      (@skipTask is false) and (@abort is false) and (@unimpl is false)

  toString: ->
    msg = super().slice(0, -1) + " #{@name}"
    if @adv isnt null then msg += " adv=#{@adv}"
    if @imm then msg += ' imm'
    if @skipTask then msg += ' skipTask'
    if @abort then msg += ' abort'
    if @unimpl then msg += ' unimpl'
    return msg + ']'

  @Again: new Res 'again', adv: 0
  @AgainImm: new Res 'again', adv: 0, imm: true

  @Next: new Res 'next', adv: 1
  @NextImm: new Res 'next_imm', adv: 1, imm: true
  @SkippedTask: (res) -> new Res 'skipped_task',
    adv: 1
    imm: res.imm
    abort: res.abort

  @Skip: (count) -> new Res 'skip', adv: count + 1
  @Skip1: Res.Skip 1
  @SkipImml: (count) -> new Res 'skip', adv: count + 1, imm: true
  @SkipImml1: Res.SkipImml 1

  @SkipTask: (count) -> new Res 'skip', skipTask: true
  @SkipTaskImm: (count) -> new Res 'skip', skipTask: true, imm: true

  @Abort: new Res 'abort', abort: true

  @Unimpl: new Res 'unimpl', unimpl: true


class TaskState extends Base
  @newFromMem: (creep, vals) ->
    state = new TaskState creep, vals
    logger.trace l"reconstituted #{state}"
    return state

  constructor: (@creep, vals) ->
    super()
    Object.assign @, vals
    Object.defineProperty @, 'creep', {}
    @stage = 0 if not @stage?

  advance: (count) -> @stage += count

  toString: ->
    super().slice(0, -1) + " c=#{@creep} s=#{@stage}]"


class Task extends Base.WithCls
  @variants = {}

  @makeNewVariant: ->
    Task.variants[@name] = @
    Task[@name] = @

  @Res: Res
  @TaskState: TaskState

  @subtasks: []
  @stages: 0

  @stagesFromSubtasks: ->
    _.sum(
      for sub in @subtasks
        if typeof sub is 'function' then 1
        else if sub instanceof Task then sub.stages
        else throw Error "invalid type in subtasks: #{sub}"
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
    subtasks:
      get: -> @constructor.subtasks

  constructor: (opts) ->
    super()

  newState: (creep) -> new TaskState creep, {}

  init: (state) ->

  logWork: (state, stage, res) ->
    logger.info l"completed #{@}.#{stage} on #{state} with #{res}"

  getSubtask: (stage) ->
    counter = 0
    # logger.debug "getSubTask for #{@}.#{stage}"
    for task, index in @subtasks
      isFunc = typeof task is 'function'
      hasTasks = if isFunc then true else (task.stages isnt 0)
      inc = if isFunc then 1 else task.stages
      if stage < counter + inc and hasTasks
        # logger.debug "getSubTask found #{index} for #{counter}"
        subtask = @subtasks[index]
        if not ((typeof subtask is 'function') or (subtask instanceof Task))
          throw Error "unknown type of task #{task}"
        return [subtask, index, counter]
      counter += inc
    return [null, null, null]

  doPrelude: (state, stage) ->
    if Game.cpu.getUsed() > Game.cpu.tickLimit / 2
      throw Error 'high cpu emergency break'
    if stage > @stages
      throw Error 'extended past last stage'
    if stage is @stages
      logger.warn 'end of tasks'
      return Res.NextImm

    return null

  doOnce: (state, offset) ->
    stage = state.stage - offset

    if (res = @doPrelude state, stage) isnt null then return res

    [subtask, index, innerOffset] = @getSubtask stage
    if subtask is null
      throw Error "could not find task using s=#{stage}"

    if subtask instanceof Task
      res = subtask.do state, innerOffset
    else
      res = subtask.call @, state
      @logWork state, stage, res
    # logger.debug "call in #{@}.#{stage} returned #{res}"

    stage = state.stage - offset

    @doPrologue state, stage, index, res

    return res

  doPrologue: (state, stage, index, res) ->
    if res not instanceof Res
      throw Error 'no result returned'
    if not res.isValid()
      throw Error 'invalid result returned'

    if res.skipTask
      stageDiff = @stages - stage
      state.advance stageDiff
      res = Res.SkippedTask res

    if res.adv isnt null
      nextStage = stage + res.adv
      [nextTask, nextIndex, nextOffset] = @getSubtask nextStage
      # do not advance past the end of this task
      if nextStage > @stages
        throw Error "advanced past end to #{state}"
      # do not advance over the bounds of a subtask
      else if nextTask isnt null and (nextIndex - index > 1)
        throw Error "bad skip to #{stage}"
      # if we're advancing to the end of this task, return
      # let the caller do the increment
      else if nextStage is @stages
        return res
      else
        state.advance res.adv

  do: (state, offset = 0) ->
    infCounter = 0
    try
      @init state
    catch e
      if not e.task?
        e.message += " in #{@}.init with #{state}"
        e.task = @
      throw e
    loop
      stage = state.stage - offset
      res = null

      try
        infCounter++
        if infCounter > 3
          throw Error "probable infinite loop"

        res = @doOnce state, offset
        # logger.debug "doOnce in #{@} returned #{res}"

      catch e
        if not e.task?
          e.message += " in #{@}.#{stage} with #{state}"
          e.task = @
        throw e

      if res.imm
        continue
      else
        return Res.Again

    throw Error "reached an unreachable statement in #{@} with #{state}"


class Task.Move extends Task
  @makeNewVariant()

  @subtasks: [
    (state) ->
      logger.debug "Debug Move action"
      return Res.Next
  ]
  @stages: do => @stagesFromSubtasks()


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

  doWork: (state, stage) ->
    super()
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


class Task.Test extends Task
  @makeNewVariant()

  @subtasks: [
    (state) ->
      logger.debug 'Task.Test.0'
      return Res.Next
    (state) ->
      logger.debug 'Task.Test.1'
      return Res.Next
    (state) ->
      logger.debug 'Task.Test.2'
      return Res.Next
  ]
  @stages: do => @stagesFromSubtasks()


module.exports = Task
