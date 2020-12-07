'use strict'

Backoff = require 'backoff'
log = require 'log'
freq = require 'freq'

logger = log.getLogger 'core'
l = log.fmt


# classes forming the core loop
# these classes are not destroyed each tick, but persist
class Core
  @toString: -> "[class #{@name}]"

  @defineMemory: (pathKind) ->
    throw Error 'requires arg pathKind' if not pathKind?
    throw Error 'requires prop initMem' if not @::initMem?
    getPath =
      if typeof pathKind is 'string' then -> @[pathKind]
      else if typeof pathKind is 'function' then -> pathKind()
      else if pathKind instanceof Array then -> pathKind
      else throw Error "invalid pathKind #{pathKind}"
    Object.defineProperty @prototype, 'memory',
      get: getMemory = ->
        return @_memory if @_memory?
        path = getPath()
        _.set(Memory, path, @initMem {}) if not _.has(Memory, path)
        return _.get(Memory, path)
      set: setMemory = (val) ->
        path = getPath()
        _.set(Memory, path, @_memory = val)
        return

  # called when the object is restored from memory
  @restore: (mem) ->

  constructor: ->
    # freq.onSafety =>
    #   throw Error 'requires ref property' if not ('ref' of @prototype)
    @backoff = new Backoff @

  toString: -> "[#{@constructor.name}]"

  # initialize a memory block
  initMem: (mem) -> mem ?= {}

  iterChildren: -> yield return

  # called when the object is being created
  # not called when the object is restored from memory
  # run super before any subclass code
  create: ->
    child.create() for child from @iterChildren()

  # called when the object is no longer needed
  # it will not be restored again
  # run super after any subclass code
  delete: ->
    child.delete() for child from @iterChildren()
    if ('memory' of @) then @memory = undefined

  # called on a code update
  # perform any actions that need to be completed
  # run super before any subclass code
  reload: ->
    child.reload() for child from @iterChildren()

  # called twice per tick, at each start and end
  # invalidate all cached data related to Game and Memory
  # run super after any subclass code
  clean: ->
    child.clean() for child from @iterChildren()
    delete @_memory

  # called once per tick
  # link any required fields in the Game object
  # run super after any subclass code
  linkGame: ->
    child.linkGame() for child from @iterChildren()

  # called once per tick
  # perform any actions that need to be completed
  # run super after any subclass code
  tick: ->
    child.tick() for child from @iterChildren()

  # called infrequently
  # perform CPU-intensive activities
  # run super after any subclass code
  refresh: ->
    child.refresh() for child from @iterChildren()

  createWithBackoff: -> @backoff.with => @create()
  deleteWithBackoff: -> @backoff.with => @delete()
  resetWithBackoff: -> @backoff.with => @reset()
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
      return @_backing = @fetchBacking()
    set: (val) ->
      @_backing = val

  constructor: (backing) ->
    super()
    freq.onSafety =>
      throw Error 'needs backing' if not backing?
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
