'use strict'

_ = require 'lodash'

Gov = require 'governors'

logger = require 'logger'
freq = require 'freq'


Room.cleanMemory = ->
  logger.info 'cleaning rooms'
  for rName of Memory.rooms
    if not Game.rooms[rName]?
      delete Memory.rooms[rName]


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
  @memory.governors[govCls.name] = new govCls @, {}


Room::detatchGov = (govCls) ->
  delete @memory.governors[govCls.name]


Room::initFirstTime = ->
  logger.info "initFirstTime for #{@}"
  @memory = {} unless @memory?
  @memory.governors = {} unless @memory.governors?
  @memory.backoff = 0


Room::init = ->
  @withBackoff ->
    freq.onReload =>
      @initFirstTime()
    logger.trace "init for #{@}"
    for gName, gov of @memory.governors
      @memory.governors[gName] = Gov.newFromMem @, gov
    return
