'use strict'

log = require 'log'
freq = require 'freq'

logger = log.getLogger 'backoff'
l = log.fmt


Memory.defaultBackoff ?= 10


class BackoffError extends Error
  constructor: (message) ->
    super message


class Backoff
  @Error = BackoffError

  @toString: -> "[class #{@name}]"

  # Object.defineProperty @prototype, 'checkedOn',
  #   get: -> return @obj.memory.checkedOn
  #   set: (val) -> @obj.memory.checkedOn = val

  Object.defineProperty @prototype, 'failedOn',
    get: getFailedOn = -> return @obj.memory.failedOn
    set: setFailedOn = (val) -> @obj.memory.failedOn = val

  Object.defineProperty @prototype, 'paused',
    get: getFailedOn = -> return @obj.memory.paused
    set: setFailedOn = (val) -> @obj.memory.paused = val

  constructor: (@obj, @backoff = Memory.defaultBackoff) ->
    freq.onSafety =>
      throw Error 'requires arg obj' if not @obj?
      throw Error 'requires obj to have memory' if not ('memory' of @obj)
      throw Error 'requires arg backoff to be int' if not _.isNumber(@backoff)
    @checkedOn = null

  toString: -> "[#{@constructor.name}]"

  withArgs: (func, opts) ->
    {error = false, rethrow = error, norecur = true} = opts

    if @checkedOn is Game.time
      throw new BackoffError "already checked backoff" if error
      return

    if @paused
      throw new BackoffError "paused" if error
      return

    if @failedOn
      escapeTime = @failedOn + @backoff
      if (Game.time < escapeTime)
        logger.info l"#{@obj} backing off for #{escapeTime - Game.time}"
        @checkedOn = Game.time if norecur
        throw new BackoffError "still in backoff" if error
        return
      else
        logger.info l"#{@obj} escapes backoff"
        @failedOn = null

    try
      return func.call @obj
    catch err
      @checkedOn = @failedOn = Game.time
      logger.info "backoff on #{@obj} for #{@backoff}"
      throw err if rethrow
      logger.error "#{err.stack}"
      return

  with: (func) -> @withArgs func, {}
  withRethrow: (func) -> @withArgs func, rethrow: true
  withErr: (func) -> @withArgs func, error: true
  withErrRecur: (func) -> @withArgs func, error: true, norecur: false

  pause: -> @pause = true
  unpause: -> @pause = undefined


module.exports = Backoff
