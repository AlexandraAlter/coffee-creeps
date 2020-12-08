'use strict'

Backoff = require 'backoff'
freq = require 'freq'
log = require 'log'

logger = log.getLogger 'core'
l = log.fmt


# classes forming the core loop
# these classes are not destroyed each tick, but persist
class Core
  @toString: -> "[class #{@name}]"
  @logger: logger

  @defineMemory: (pathKind) ->
    throw Error 'requires arg pathKind' if not pathKind?
    throw Error 'requires prop initMem' if not @::initMem?

    getPath =
      if typeof pathKind is 'string' then -> @[pathKind]
      else if typeof pathKind is 'function' then pathKind
      else if pathKind instanceof Array then -> pathKind
      else throw Error "invalid pathKind #{pathKind}"

    Object.defineProperty @prototype, 'memory',
      get: getMemory = ->
        return @_memory if @_memory?
        path = getPath.call @
        _.set(Memory, path, @initMem {}) if not _.has(Memory, path)
        return _.get(Memory, path)
      set: setMemory = (val) ->
        path = getPath.call @
        _.set(Memory, path, @_memory = val)
        return

  Object.defineProperty @prototype, 'sys',
    get: getSys = -> Sys

  Object.defineProperty @prototype, 'logger',
    get: getLogger = -> @constructor.logger

  constructor: ->
    freq.onSafety =>
      throw Error 'no memory defined' if not ('memory' of @)
      throw Error 'requires sys' if not @sys?
    @backoff = new Backoff @

  toString: -> "[#{@constructor.name}]"
  toJSON: -> @toString()

  # initialize a memory block
  initMem: (mem) -> mem ?= {}

  iterChildren: -> yield return

  # called when the object is being created
  # not called when the object is restored from memory
  # run super before any subclass code
  create: ->
    for child from @iterChildren()
      log.catchVar 'child', child, => child.create()

  # called when the object is no longer needed
  # it will not be restored again
  # run super after any subclass code
  delete: ->
    for child from @iterChildren()
      log.catchVar 'child', child, => child.delete()
    if ('memory' of @) then @memory = undefined

  # called on a code update
  # perform any actions that need to be completed
  # run super after any subclass code
  reload: ->
    @logger.trace l"reload for #{@}"
    for child from @iterChildren()
      log.catchVar 'child@reload', child, => child.reload()

  # called twice per tick, at each start and end
  # invalidate all cached data related to Game and Memory
  # run super after any subclass code
  clean: ->
    @logger.trace l"clean for #{@}"
    for child from @iterChildren()
      log.catchVar 'child@clean', child, => child.cleanWithBackoff()
    delete @_memory

  # called once per tick
  # link any required fields in the Game object
  # run super after any subclass code
  linkGame: ->
    @logger.trace l"linkGame for #{@}"
    for child from @iterChildren()
      log.catchVar 'child@linkGame', child, => child.linkGameWithBackoff()

  # called infrequently
  # perform CPU-intensive activities
  # run super after any subclass code
  refresh: ->
    @logger.trace l"refresh for #{@}"
    for child from @iterChildren()
      log.catchVar 'child@refresh', child, => child.refreshWithBackoff()

  # called once per tick
  # perform any actions that need to be completed
  # run super after any subclass code
  tick: ->
    @logger.trace l"tick for #{@}"
    for child from @iterChildren()
      log.catchVar 'child@tick', child, => child.tickWithBackoff()

  cleanWithBackoff: -> @backoff.with => @clean()
  linkGameWithBackoff: -> @backoff.with => @linkGame()
  tickWithBackoff: -> @backoff.with => @tick()
  refreshWithBackoff: -> @backoff.with => @refresh()


# core classes that are backed by an in-Game object
class Core.Backed extends Core
  # the class of the backing object
  @backingCls = null

  # called on a code update
  # link any required fields in the global prototypes
  @linkProto: ->
    if @backingCls?
      @backingCls.coreCls = @

  # create a new instance from a backing object
  # unfinished, must extend
  @from: (backing) ->
    coreCls = backing?.constructor?.coreCls ? @
    backingCls = coreCls.backingCls
    freq.onSafety =>
      if not coreCls?
        throw Error "no backing class for #{@} with #{backing}"
      if backing not instanceof backingCls
        throw Error 'backing of invalid class'
    return new coreCls backing

  Object.defineProperty @prototype, 'backing',
    get: ->
      return @_backing if @_backing?
      @_backing = @fetchBacking()
      throw Error 'no backing retrieved' if not @_backing?
      @_backing
    set: (val) ->
      @_backing = val

  constructor: (backing) ->
    super()
    freq.onSafety =>
      throw Error 'needs backing' if not backing?
      throw Error 'Core is virtual' if @constructor is Core
    @backing = backing

  # called potentially every tick
  # finds a backing object in Game
  fetchBacking: -> throw Error 'must override fetchBacking'

  # called occasionally
  # reports whether this object still has an in-Game backing object
  exists: -> throw Error 'must override exists'

  # overrides Core::reset
  reset: ->
    super()
    @delete() if not @exists()

  # overrides Core::clean
  clean: ->
    super()
    delete @_backing

  linkGame: ->
    @backing.core = @
    super()

module.exports = Core
