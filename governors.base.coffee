'use strict'

Edict = require 'edicts'
logger = require 'logger'


class Gov
  @variants: {}

  @toJSON: ->
    'class ' + @name

  # returns true if the given room requires this governor
  @requiredInRoom: (room, maybeGov) ->
    false

  #currently in governers.coffee
  # @newFromMem: (room, opts) ->
  #   try
  #     cls = @variants[opts.cls]
  #     new cls room, opts
  #   catch err
  #     logger.error 'Governor construction from memory failed\n', err.stack

  constructor: (@room, opts) ->
    {@edicts} = opts

    @edicts = if @edicts
      for eName, e of @edicts
        @edicts[eName] = Edict.newFromMem @, e
    else {}

    @room.memory.governors[@constructor.name] = @

    Object.defineProperty @, 'room',
      enumerable: false

  # initialize the governor
  tick: ->
  updateEdicts: ->

  toString: ->
    edictNum = Object.keys(@edicts).length
    "#{@constructor.name}(n=#{@name}, r=#{@room.name}, e=#{edictNum})"

  toJSON: -> {
    cls: @constructor.name,
    @...,
  }


module.exports = Gov
