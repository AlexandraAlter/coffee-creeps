'use strict'

Base = require 'base'
logger = require 'logger'
l = logger.fmt
freq = require 'freq'


class Task extends Base
  @variants = {}

  @stages: 1

  @makeNewVariant: ->
    Task.variants[@name] = @
    Task[@name] = @

  @newFromMem: (creep, opts) ->
    cls = @variants[opts.cls]
    task = new cls creep, opts
    logger.trace l"reconstituted #{task}"
    return task

  constructor: (@creep, opts) ->
    super()
    {} = opts

  do: ->
  isDone: ->


class Task.Staged extends Task
  @stages: 0

  constructor: (creep, opts) ->
    super creep, opts
    { @stage = 0 } = opts

  do: ->
    if @stage >= @constructor.stages
      @deadStage()

  isDone: ->
    @stage >= @constructor.stages

  deadStage: ->
    logger.warn l"#{@} extended past last stage"

  toString: ->
    super().slice(0, -1) + " s=#{stage}]"


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

  constructor: (creep, opts) ->
    super creep, opts
    {} = opts

  do: ->
    curStage = @stage
    counter = 0
    for task in @constructor.subTasks
      if counter <= task.stages
        @stage -= counter
        task::do.call @
        @stage += counter
        break
      else
        counter += task.stages

  isDone: ->
    @stage >= @constructor.stages

  toString: ->
    super().slice(0, -1) + " s=#{stage}]"


class Task.Move extends Task
  @makeNewVariant()

  constructor: (creep, opts) ->
    super creep, opts
    { @target } = opts

  do: ->
    res = @creep.move @target
    if res isnt OK
      logger.error l"#{@creep} failed to move with #{res}"

  isDone: ->
    @creep.pos.getRangeTo @target <= 1


class Task.GetEnergy extends Task.Nested
  @makeNewVariant()

  @subTasks: [Task.Move, 0, 1]
  @stages: do => @calcStages()

  constructor: (creep, opts) ->
    super creep, opts
    { @target } = opts

  do: ->
    if @stage is 0
      Task.Move.do.call @
      if Task.Move.isDone.call @
        @stage++
    else if @stage is 1
      @creep.harvest @target
      if @creep.store.getFreeCapacity() is 0
        @stage++
    else
      super()


module.exports = Task
