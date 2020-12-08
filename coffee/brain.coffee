'use strict'

Core = require 'core'
Backoff = require 'backoff'
log = require 'log'
freq = require 'freq'

logger = log.getLogger 'brain'
l = log.fmt


class Brain extends Core
  Object.defineProperty @prototype, 'ref',
    get: getRef = -> 'brain'

  @defineMemory ['brain']

  constructor: () ->
    super()
    @cortexes = []

  iterChildren: ->
    if @cortexes?
      yield cortex for cortex in @cortexes

  reload: ->
    @cortexes = (new cortexType for cortexType from @sys.cortexTypes())
    super()


module.exports = Brain

