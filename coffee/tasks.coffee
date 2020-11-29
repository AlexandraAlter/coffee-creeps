'use strict'

Base = require 'base'
logger = require 'logger'
l = logger.fmt
freq = require 'freq'


status =
  OK: 0
  NEXT: 1
  NEXT_AGAIN: 2


class Task extends Base
  @variants = {}

  @stages: 1

  @makeNewVariant: ->
    Task.variants[@name] = @
    Task[@name] = @

  @toJSON: -> @name

  @clsFromMem: (str) ->
    cls = @variants[str]
    throw 'invalid class' if not cls?
    return cls

  @newFromMem: (creep, opts) ->
    cls = @variants[opts.cls]
    task = new cls creep, opts
    logger.trace l"reconstituted #{task}"
    return task

  @do: (task) ->
  @isDone: (task) ->

  constructor: (@creep, opts) ->
    super()
    {} = opts

    Object.defineProperty @, 'creep', enumerable: false


class Task.Staged extends Task
  @stages: 0

  @do: (task) ->
    if task.stage >= @stages
      @deadStage task

  @isDone: (task) ->
    task.stage >= @stages

  @deadStage: (task) ->
    logger.warn l"#{@} with #{task} extended past last stage"

  constructor: (creep, opts) ->
    super creep, opts
    { @stage = 0 } = opts

  toString: ->
    super().slice(0, -1) + " s=#{@stage}]"


class Task.Nested extends Task.Staged
  @subTasks: []

  @calcStages: ->
    ownTasks = 0
    _.sum(
      for sub in @subTasks
        if typeof sub is 'number'
          if freq.onSafety and (sub isnt ownTasks)
            logger.warn l"incorrectly numbered task in #{@}:#{sub}"
          ownTasks++
          1
        else
          sub.stages
    )

  @stages: do => @calcStages()

  @doStage: (task) ->
    @deadStage task

  @do: (task) ->
    counter = 0
    for subTask in @subTasks
      ownedTask = _.isFinite(subTask)
      countOffset = if ownedTask then 0 else subTask.stages
      if counter <= task.stage + countOffset
        if ownedTask
          stageOffset = subTask.stages - task.stage
          task.stage -= stageOffset
          @doStage task
          task.stage += stageOffset
        else
          task.stage -= counter
          subTask.do task
          task.stage += counter
        return
      else
        counter += if ownedTask then 1 else t.stages
    throw Error('reached end of task list')

  constructor: (creep, opts) ->
    super creep, opts
    {} = opts


class Task.Move extends Task
  @makeNewVariant()

  @do: (task) ->
    res = task.creep.moveTo task.target
    if res isnt OK
      logger.warn l"#{task.creep} failed to move with #{res}"

  @isDone: (task) ->
    task.creep.pos.getRangeTo task.target <= 1

  constructor: (creep, opts) ->
    super creep, opts
    { @target } = opts


class Task.GetEnergy extends Task.Nested
  @makeNewVariant()

  @subTasks: [Task.Move, 0, 1]
  @stages: do => @calcStages()

  @doStage: (task) ->
    if task.stage is 0
      res = task.creep.harvest task.target
      if res isnt OK
        logger.warn l"#{task.creep} failed to harvest with #{res}"
      if task.creep.store.getFreeCapacity() is 0
        task.stage++
    else if task.stage is 1
      task.stage++
    else
      @deadStage()

  constructor: (creep, opts) ->
    super creep, opts
    { @target } = opts


class Task.Refill extends Task.Nested
  @makeNewVariant()

  @subTasks: [Task.GetEnergy]
  @stages: do => @calcStages()

  @do: (task) ->
    super task

  constructor: (creep, opts) ->
    super creep, opts
    { @target } = opts
    if typeof @target is 'string'
      @target = Game.getObjectById @target

  toJSON: -> {
    @...,
    target: @target.id,
  }

  toString: ->
    super().slice(0, -1) + " t=#{@target.id}]"


module.exports = Task
