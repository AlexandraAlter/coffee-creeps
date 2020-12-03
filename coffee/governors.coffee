'use strict'

Edict = require 'edicts'
Base = require 'base'

freq = require 'freq'
logger = require 'logger'


class Gov extends Base.WithCls
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
    cls = @variants[opts.cls]
    gov = new cls room, opts
    logger.trace "reconstituted #{gov}"
    return gov

  constructor: (@room, opts) ->
    super()

    Object.defineProperty @, 'room', enumerable: false

    {@edicts = {}, @backoff = 0} = opts
    Object.defineProperty @, 'backedOff',
      enumerable: false
      value: false

    for eName, e of @edicts
      @edicts[eName] = Edict.newFromMem @, e

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
      logger.info "gov backoff for #{@cls}"
      throw err

  initFirstTime: ->

  tick: ->
    @withBackoff ->
      logger.trace "gov tick for #{@cls}"
      freq.onReload =>
        @initFirstTime()
      return

  makeEdict: (name, edictCls, opts) ->
    if @edicts[name]
      for k, v of opts
        @edicts[name][k] = v
      @edicts[name].name = name
    else
      @edicts[name] = new edictCls @, {name: name, opts...}

  updateEdicts: ->
    for eName, edict of @edicts
      edict.update()

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

  clean: ->
    for eName, edict of @edicts
      edict.clean()

  toString: ->
    edictNum = Object.keys(@edicts).length
    "[#{@cls} r=#{@room.name} e=#{edictNum}]"


module.exports = Gov
