'use strict'


class Task
  @variants = {}

  constructor: (@creep, opts) ->
    {} = opts

  toString: -> @constructor.name

  step: ->
  isDone: ->


class Task.Move extends Task
  Task.variants[@name] = @

  constructor: (creep, opts) ->
    super creep, opts
    { @target } = opts

  step: ->
    @creep.move @target

  isDone: ->
    @creep.pos.getRangeTo @target <= 1


module.exports = Task
