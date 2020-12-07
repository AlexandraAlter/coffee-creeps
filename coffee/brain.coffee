'use strict'

Core = require 'core'
Backoff = require 'backoff'
log = require 'log'
freq = require 'freq'
cortexes = require 'cortexes'

logger = log.getLogger 'brain'
l = log.fmt


class Brain extends Core
  Object.defineProperty @prototype, 'ref',
    get: getRef = -> 'brain'

  @defineMemory ''

  constructor: (@sys) ->
    super()
    freq.onSafety =>
      throw Error 'requires sys' if not @sys?
    @cortexes = []
    @zones = null

  reset: ->
    @backoff.reset()
    delete @_memory
    @cortexes = @sys.cortexes
    @zones = @sys.zones

  setup: ->


module.exports = Brain

