'use strict'

_ = require 'lodash'

roles = require 'roles'
Gov = require 'governors'
logger = require 'logger'
u = require 'utils'


Room::withBackoff = (func) ->
  if @backedOff
    return

  if @memory.backoff? and @memory.backoff > 0
    @memory.backoff--
    @backedOff = true
    return

  try
    return func.call @
  catch err
    @memory.backoff = 10
    logger.info "room backoff for #{@name}", indent: 1
    throw err


Room::attachGov = (govCls) ->
  @memory.governors[govCls.constructor.name] = new govCls @, {}


Room::detatchGov = (govCls) ->
  delete @memory.governors[govCls.name]


Room::initFirstTime = ->
  logger.info "first time init for #{@}"
  @memory = {} unless @memory?
  @memory.governors = {} unless @memory.governors?
  @memory.backoff = 0


Room::init = ->
  @withBackoff ->
    if u.onFreq u.freq.RELOAD
      @initFirstTime()
    logger.trace "room tick for #{@name}", indent: 1
    for gName, gov of @memory.governors
      @memory.governors[gName] = Gov.newFromMem @, gov
    return


# class Room
#   constructor: (@inner) ->
#     Object.defineProperty this, 'mem',
#       get: ->
#         @inner.mem or (@inner.mem = {})

#   getReqs: ->
#     @mem.reqs or (@mem.reqs = defaultReqs(@inner))

#   getMissingReqs: ->
#     if @missing? then return @missing

#     reqs = @getReqs()
#     creeps = @inner.find FIND_MY_CREEPS
#     missing = []

#     for name, role of reqs.creeps
#       if _.find creeps, (c) -> c.name is name
#         continue
#       else
#         missing.push { name, role }

#     return @missing = missing

