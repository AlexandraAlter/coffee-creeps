'use strict'

Core = require 'core'
Backoff = require 'backoff'
Rehydrator = require 'rehydrator'
log = require 'log'
freq = require 'freq'

logger = log.getLogger 'node'
l = log.fmt


class Node extends Core
  @rehydrator = new Rehydrator @

  Object.defineProperty @prototype, 'ref',
    get: getRef = -> @name

  @defineMemory -> @room.memory.nodes

  constuctor: ->
    super()
    @name = 'foo'
    @room = null


module.exports = Node
