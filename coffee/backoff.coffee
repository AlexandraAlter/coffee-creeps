'use strict'

freq = require 'freq'


class Backoff
  @toString: -> "[class #{@name}]"

  Object.defineProperty @prototype, 'backoff',
    get: -> return @obj.memory.backoff
    set: (val) -> @obj.memory.backoff = val

  constructor: (@obj) ->
    Object.defineProperty @, 'backedOff', value: false, writable: true
    freq.onSafety =>
      throw Error 'requires obj' if not @obj?
      throw Error 'requires obj' if not ('memory' of @obj)?

  toString: -> "[#{@constructor.name}]"

  with: (func) ->
    @backoff = 0 if not _.isNumber @backoff
    if @backedOff
      return
    if @backoff > 0
      @backoff--
      @backedOff = true
      return
    try
      return func.call @obj
    catch err
      @backoff = 10
      logger.info "gov backoff for #{@cls}"
      throw err

  reset: ->
    @backedOff = false


module.exports = Backoff
