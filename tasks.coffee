'use strict'


class Task
  @variants = {}

  constructor: (@creep, opts) ->
    @creep.task = @
    {} = opts

  toString: -> @constructor.name

  do: ->
  isDone: ->


class Task.Move extends Task
  Task.variants[@name] = @

  constructor: (creep, opts) ->
    super creep, opts
    { @target } = opts

  do: ->
    @creep.move @target

  isDone: ->
    @creep.pos.getRangeTo @target <= 1


module.exports = Task
