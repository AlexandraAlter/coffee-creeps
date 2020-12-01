'use strict'

Base = require 'base'
logger = require 'logger'
l = logger.fmt
freq = require 'freq'


Res =
  AGAIN: 0
  NEXT: -1
  NEXT_IMM: -2
  SKIP_SUBTASK: -5
  SKIP_SUBTASK_IMM: -6
  UNIMPL: -7
  SKIP: 1
  SKIP_2: 2
  SKIP_3: 3


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
    Object.defineProperty @, 'blocked',
      enumerable: false
      writable: true
      value: false
    Object.defineProperty @, 'continuing',
      enumerable: false
      writable: true
      value: false
    Object.defineProperty @, 'stageOffset',
      enumerable: false
      writable: true
    @stage = 0 if not @stage?

  init: ->
    @blocked = false
    @continuing = false
    @stageOffset = null

  changeStage: (offset) ->
    @stage += offset
    @stageOffset = offset

  handleRes: (res) ->
    if res is Res.AGAIN
      @blocked = true
      0
    else if res is Res.NEXT
      @blocked = true
      @changeStage 1
    else if res is Res.NEXT_IMM
      @continuing = true
      @changeStage 1
    else if res > 0
      @continuing = true
      @changeStage res
      return res
    else if res is Res.SKIP_SUBTASK
      throw Error "SKIP_SUBTASK isn't implemented yet"
    else if res is Res.SKIP_SUBTASK_IMM
      throw Error "SKIP_SUBTASK_IMM isn't implemented yet"
    else if res is Res.UNIMPL
      throw Error "hit unimplemented method for #{@}"
    else
      throw Error "unknown task result #{res} for #{@}"

  toString: ->
    "[#{@constructor.name} c=#{@creep} s=#{@stage}]"


class Task extends Base
  @variants = {}

  @makeNewVariant: ->
    Task.variants[@name] = @
    Task[@name] = @

  @Res: Res
  @TaskState: TaskState

  @subTasks: null
  @stages: 0

  @stagesFromSubTasks: ->
    ownTasks = 0
    _.sum(
      for sub in @subTasks
        if typeof sub is 'function'
          1
        else if sub instanceof Task
          sub.getStages()
        else
          throw Error "invalid type in subTasks: #{sub}"
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

  constructor: (opts) ->
    super()

  getStages: -> @constructor.stages
  getSubTasks: -> @constructor.subTasks

  newState: (creep) -> new TaskState creep, {}

  init: (state) ->

  doSubTask: (state, stage) ->
    res = subTask = subStage = null
    counter = 0

    for task in @getSubTasks()
      isFunc = typeof task is 'function'
      if stage <= counter
        subTask = task
        subStage = stage - counter
        break
      else
        counter += if isFunc then 1 else task.getStages()

    if not subTask
      @deadStage state

    else if typeof subTask is 'function'
      # run the subtask
      res = subTask.call @, state
      logger.trace l"#{@}.#{stage} on #{state} completed with #{res}"

    else if subTask instanceof Task
      subTask.do state, subStage

    else
      throw Error "unknown type of subTask #{subTask}"

    # return the new stage, in case it changed
    return res

  doWork: (state, stage) ->
    logger.info l"#{@} running on #{state}"
    return Res.UNIMPL

  do: (state, stage = null) ->
    stage = state.stage if not stage
    infCounter = 0
    @init state
    loop
      state.init()

      res = null
      if @isDone state
        @deadStage state
      else if @getSubTasks()
        counter = 0
        res = @doSubTask state, stage
      else
        res = @doWork state, stage

      if res isnt null
        stage += state.handleRes res

      infCounter++
      if infCounter > 5
        throw Error "probable infinite loop in #{@} with #{state}"

      if Game.cpu.getUsed() > Game.cpu.tickLimit / 2
        throw Error "high cpu emergency break"

      if state.blocked
        break
      else if state.continuing
        continue
      else
        throw Error "state #{state} neither blocked nor continued in #{@}"

  isDone: (state) ->
    state.stage >= @getStages()

  deadStage: (state, stage) ->
    logger.warn l"#{@}.#{stage} with #{state} extended past last stage"


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
      return Res.NEXT
    else
      return Res.AGAIN

  isDone: (state) ->
    state.creep.pos.getRangeTo state.target <= 1


class Task.GetEnergy extends Task
  @makeNewVariant()

  @subTasks: [
    (state) ->
      logger.debug "GetEnergy.0"
      source = state.creep.pos.findClosestByRange FIND_SOURCES_ACTIVE
      state.sourceId = source.id
      state.sourceCache = source
      return Res.NEXT_IMM
    new Task.Move
      idName: 'sourceId'
      cacheName: 'sourceCache'
    (state) ->
      logger.debug "GetEnergy.2"
      res = state.creep.harvest state.target
      if res isnt OK
        logger.warn l"#{state.creep} failed to harvest with #{res}"
      if state.creep.store.getFreeCapacity() is 0
        return Res.NEXT
      else
        return Res.AGAIN
  ]
  @stages: do => @stagesFromSubTasks()

  init: (state) ->
    if not state.targetCache?
      Object.defineProperty state, 'targetCache',
        value: Game.getObjectById state.targetId
        enumerable: false


class Task.Refill extends Task
  @makeNewVariant()

  @subTasks: [
    new Task.GetEnergy
  ]
  @stages: do => @stagesFromSubTasks()

  init: (state) ->
    if not state.targetCache?
      Object.defineProperty state, 'targetCache',
        value: Game.getObjectById state.targetId
        enumerable: false


module.exports = Task
