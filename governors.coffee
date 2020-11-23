'use strict'

logger = require 'logger'
Gov = require 'governors.base'


newFromMem = (room, opts) ->
  try
    cls = Gov.variants[opts.cls]
    new cls room, opts
  catch err
    logger.error 'Governor construction from memory failed\n', err.stack


newIfRequired = (room) ->
  for gName, gov of Gov.variants
    curGov = room.memory.governors[gov.name]
    if not curGov? and gov.requiredInRoom room, curGov
      logger.info "attaching gov #{gov.name} to room #{room.name}"
      new gov room, {}


delIfRequired = (room) ->
  for gName, gov of Gov.variants
    curGov = room.memory.governors[gov.name]
    if curGov? and not gov.requiredInRoom room, curGov
      logger.info "deleting gov #{gov.name} from room #{room.name}"
      delete room.memory.governors[gov.name]


module.exports = {
  Gov,
  newFromMem,
  newIfRequired,
  delIfRequired,
  UpkeepGov: require 'governors.upkeep',
  BuildingGov: require 'governors.building',
  CombatGov: require 'governors.combat',
}
