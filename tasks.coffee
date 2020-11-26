'use strict'

Base = require 'base'

logger = require 'logger'


class Task extends Base
  @variants = {}

  @makeNewVariant: ->
    Task.variants[@name] = @
    Task[@name] = @


  @newFromMem: (creep, opts) ->
    try
      cls = @variants[opts.cls]
      task = new cls creep, opts
      logger.trace "reconstituted #{task}"
      return task
    catch err
      logger.error "Task.newFromMem failed\n#{err.stack}"
      return


  constructor: (@creep, opts) ->
    super()
    @creep.task = @
    {} = opts


  do: ->
  isDone: ->


class Task.Move extends Task
  @makeNewVariant()


  constructor: (creep, opts) ->
    super creep, opts
    { @target } = opts


  do: ->
    @creep.move @target


  isDone: ->
    @creep.pos.getRangeTo @target <= 1


module.exports = Task
