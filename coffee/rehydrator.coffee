'use strict'

freq = require 'freq'


class Rehydrator
  @toString: ->
    "[class #{@name}]"

  @instances: new WeakSet

  constructor: (@baseCls) ->
    freq.onSafety =>
      throw Error 'no base class given' if not @baseCls?
    @classes = {}
    @constructor.instances.add(@)

  toString: ->
    "[#{@constructor.name}]"

  register: (cls) ->
    cls.fullName = @baseCls.name + '.' + cls.name
    @classes[cls.fullName] = cls
    return

  getCls: (str) ->
    cls = @classes[str]
    throw Error "invalid variant #{str} in #{@}" if not cls?
    return cls

  rehydrate: (args..., mem) ->
    cls = @getCls mem.cls
    obj = new cls args..., mem
    if not obj?
      json = JSON.stringify [args..., mem]
      throw Error "failed new #{cls} in #{@} with #{json}"

  [Symbol.iterator]: -> @classes[Symbol.iterator]


module.exports = Rehydrator
