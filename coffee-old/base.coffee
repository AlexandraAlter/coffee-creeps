'use strict'

Backoff = require 'backoff'
freq = require 'freq'


class GameObj extends Pretty
  @innerCls = null

  @defineMemory: (path) ->
    if typeof path isnt 'function'
      getRoot = -> _.get(Memory, path)
    else getRoot = path
    Object.defineProperty @prototype, 'memory',
      get: ->
        return @_memory if @_memory?
        Memory[path] ?= {}
        return @_memory = getRoot.call(@)[@toRef] ?= @cleanMem {}
      set: (val) -> @_memory = getRoot.call(@)[@toRef] = val

  constructor: ->
    super()
    @onDelete = []
    @backoff = new Backoff
    freq.onSafety =>
      throw Error 'requires toRef definition' if not @toRef?

  toString: -> "[#{@constructor.name}]"

  addOnDelete: (func) -> @onDelete.push func

  delete: ->
    for func in @onDelete
      func @
    if @memory?
      @memory = undefined

  # called occasionally
  # reports whether this object still has an in-Game backing object
  exists: -> false

  # called on a code update
  # perform any actions that need to be completed
  reset: ->
    if not @exists()
      @delete()

  # called twice per tick
  # invalidate all cached data related to Game and Memory
  clean: ->
    delete @_memory

  # called once per tick
  # link any required fields in the game object
  link: ->

  # called once per tick
  # perform any actions that need to be completed
  tick: ->

  # called infrequently
  # perform CPU-intensive activities
  refresh: ->


module.exports = {
  Pretty
  GameObj
}
