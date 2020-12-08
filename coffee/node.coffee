'use strict'

Core = require 'core'
Backoff = require 'backoff'
Rehydrator = require 'rehydrator'
freq = require 'freq'
log = require 'log'

logger = log.getLogger 'node'
l = log.fmt

Memory.nodeTtl ?= 30


class Node extends Core
  @rehydrator: new Rehydrator @
  @logger: logger

  Object.defineProperty @prototype, 'ref',
    get: getRef = -> @name

  @defineMemory -> @zone.memory[@name]

  constructor: (@name, @zone, opts) ->
    super()
    freq.onSafety =>
      throw Error 'Node is virtual' if @constructor is Node
      throw Error 'requires arg name' if not @name?
      throw Error 'requires arg zone' if not @zone?
      throw Error 'requires arg opts' if not opts?
    Node.rehydrator.notate @
    @memory.ttl = Game.time + Memory.nodeTtl

  tick: ->
    @delete() if Game.time > @memory.ttl


module.exports = Node
