'use strict'

Edict = require 'edicts'
Base = require 'base'

logger = require 'logger'


class Gov extends Base
  @variants: {}

  @makeNewVariant: ->
    Gov.variants[@name] = @
    Gov[@name] = @

  @allVariants:

    newIfRequired: (room) ->
      logger.trace "adding govs in #{room}"
      for gName, govCls of Gov.variants
        curGov = room.memory.governors[govCls.name]
        if not curGov? and govCls.requiredInRoom room, curGov
          logger.info "attaching #{govCls}"
          room.attachGov(govCls)


    delIfRequired: (room) ->
      logger.trace "deleting govs in #{room}"
      for gName, govCls of Gov.variants
        curGov = room.memory.governors[govCls.name]
        if curGov? and not govCls.requiredInRoom room, curGov
          logger.info "deleting #{govCls}"
          room.detatchGov(govCls)


  # returns true if the given room requires this governor
  @requiredInRoom: (room, maybeGov) ->
    false


  @newFromMem: (room, opts) ->
    try
      cls = @variants[opts.cls]
      gov = new cls room, opts
      logger.trace "reconstituted #{gov}"
      return gov
    catch err
      logger.error 'Gov.newFromMem failed\n', err.stack
      return


  constructor: (@room, opts) ->
    super()

    Object.defineProperty @, 'room',
      enumerable: false

    {@edicts, @backoff = 0} = opts
    Object.defineProperty @, 'backedOff',
      enumerable: false
      value: false

    @edicts = if @edicts
      for eName, e of @edicts
        @edicts[eName] = Edict.newFromMem @, e
    else {}


  withBackoff: (func) ->
    if @backedOff
      return
    if @backoff > 0
      @backoff--
      @backedOff = true
      return
    try
      return func.call @
    catch err
      @backoff = 10
      logger.info "gov backoff for #{@name}"
      throw err


  initFirstTime: ->


  tick: ->
    @withBackoff ->
      logger.trace "gov tick for #{@name}"
      if u.onFreq u.freq.RELOAD
        @initFirstTime()
      return


  updateEdicts: ->


  assignEdicts: ->
    @withBackoff ->
      logger.trace "assigning edicts for #{@}"
      for edict of @edicts
        logger.trace "considering #{edict}", indent: 1
        assigned = false
        for creep of Game.creeps
          if false
            logger.withIndent =>
              edict.assignTo creep
            assigned = true
            break
        if not assigned
          logger.trace "could not assign #{edict}", indent: 2


  toString: ->
    edictNum = Object.keys(@edicts).length
    "[#{@cls}(n=#{@name}, r=#{@room.name}, e=#{edictNum})]"


module.exports = Gov
