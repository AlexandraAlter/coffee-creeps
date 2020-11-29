'use strict'

Base = require 'base'

logger = require 'logger'


class Task extends Base
  @variants = {}

  @makeNewVariant: ->
    Task.variants[@name] = @
    Task[@name] = @

  @newFromMem: (creep, opts) ->
    cls = @variants[opts.cls]
    task = new cls creep, opts
    logger.trace "reconstituted #{task}"
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

  isDone: ->
    @stage is 0

  deadStage: ->
    logger.error "#{@} extended past last stage"

  toString: ->
    super().slice(0, -1) + " s=#{stage}]"


class Task.Nested extends Task.Staged
  @subTasks: []

  @stages: do =>
    @subTasks.length

  constructor: (creep, opts) ->
    super creep, opts
    { @stage = 0 } = opts

  isDone: ->
    @stage is 0

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
      logger.error "#{@creep} failed to move with #{res}"

  isDone: ->
    @creep.pos.getRangeTo @target <= 1


class Task.GetEnergy extends Task.Staged
  @makeNewVariant()

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
      @deadStage()

  isDone: ->
    @stage is 2


module.exports = Task
