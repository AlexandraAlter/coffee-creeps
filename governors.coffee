'use strict'

logger = require 'logger'

Edict = require 'edicts'


class Gov
  @variants: {}

  @makeNewVariant: ->
    Gov.variants[@name] = @
    Gov[@name] = @

  @allVariants:

    newIfRequired: (room) ->
      for gName, gov of @variants
        curGov = room.memory.governors[gov.cls]
        if not curGov? and gov.requiredInRoom room, curGov
          logger.info "attaching gov #{gov.name} to room #{room.name}"
          new gov room, {}

    delIfRequired: (room) ->
      for gName, gov of @variants
        curGov = room.memory.governors[gov.cls]
        if curGov? and not gov.requiredInRoom room, curGov
          logger.info "deleting gov #{gov.name} from room #{room.name}"
          delete room.memory.governors[gov.name]

  @toJSON: ->
    'class ' + @name

  # returns true if the given room requires this governor
  @requiredInRoom: (room, maybeGov) ->
    false

  @newFromMem: (room, opts) ->
    try
      cls = @variants[opts.cls]
      gov = new cls room, opts
      logger.trace 'reconstituted Gov', gov, indent: 2
      return gov
    catch err
      logger.error 'Gov.newFromMem failed\n', err.stack, indent: 2
      return

  constructor: (@room, opts) ->
    @cls = @constructor.name

    @room.memory.governors[@constructor.name] = @
    Object.defineProperty @, 'room',
      enumerable: false

    {@edicts} = opts
    @edicts = if @edicts
      for eName, e of @edicts
        @edicts[eName] = Edict.newFromMem @, e
    else {}

  tick: ->
  updateEdicts: ->

  assignEdicts: ->
    logger.trace 'assigning Edicts for Gov', @cls, indent: 2
    for edict of @edicts
      logger.trace 'considering Edict', edict, indent: 3

  toString: ->
    edictNum = Object.keys(@edicts).length
    "#{@constructor.name}(n=#{@name}, r=#{@room.name}, e=#{edictNum})"

  toJSON: -> {
    cls: @constructor.name,
    @...,
  }


module.exports = Gov
