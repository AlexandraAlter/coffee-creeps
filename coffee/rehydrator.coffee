'use strict'

log = require 'log'
freq = require 'freq'

logger = log.getLogger 'rehydrator'
l = log.fmt


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

  getCls: (str) ->
    cls = @classes[str]
    throw Error "invalid variant #{str} in #{@}" if not cls?
    return cls

  register: (cls) ->
    freq.onSafety =>
      throw Error 'no memory defined' if not ('memory' of cls::)
    cls.fullName = @baseCls.name + '.' + cls.name
    @classes[cls.fullName] = cls
    return

  from: (args..., mem) ->
    cls = @getCls mem.cls
    obj = new cls args..., mem
    if not obj?
      json = JSON.stringify [args..., mem]
      throw Error "failed new #{cls} in #{@} with #{json}"

  fromIfValid: (args..., mem) ->
    cls = @classes[mem.cls]
    return new cls args..., mem if cls?

  # embed properties used for object rehydration into an object
  # currently only
  notate: (obj) ->
    fn = obj.constructor.fullName
    throw Error "invalid object to notate #{obj}" if not fn?
    obj.cls = fn
    return obj

  [Symbol.iterator]: -> @classes[Symbol.iterator]


module.exports = Rehydrator
