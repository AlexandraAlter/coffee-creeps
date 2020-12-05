'use strict'

_ = require 'lodash'

Gov = require 'governors'

logger = require 'logger'
freq = require 'freq'


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


cleanMemory = ->
  logger.info 'cleaning rooms'
  for rName of Memory.rooms
    if not Game.rooms[rName]?
      delete Memory.rooms[rName]


tick = ->
  for rName, room of Game.rooms
    room.init()

    freq.onRareOrReload 0, =>
      logger.info l"refreshing govs in #{room}"
      logger.withIndent =>
        Gov.allVariants.delIfRequired room
        Gov.allVariants.newIfRequired room

    for gName, gov of room.memory.governors
      gov.tick()
      gov.updateEdicts()
      freq.onRareOrReload 0, =>
        logger.info l"cleaning govs in #{room}"
        gov.clean()

  freq.onRare 1, =>
    cleanMemory()


module.exports = {
  cleanMemory
  tick
}
