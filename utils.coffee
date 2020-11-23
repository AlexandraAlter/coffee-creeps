'use strict'

logger = require 'logger'


priority =
  V_LOW: 1
  LOW: 2
  MED: 3
  HIGH: 4
  V_HIGH: 5
  CRIT: 6
  XTRM: 7


freq =
  EVERY: 1
  E_OTHER: 2
  SOMETIMES: 5
  OCCASIONALLY: 10
  RARELY: 50
  V_RARELY: 500
  RELOAD: Symbol()


logger.info 'reloading'
firstLoadTime = Game.time


onFreq = (f, offset = 0) ->
  if f is freq.RELOAD
    Game.time is firstLoadTime
  else
    if offset >= f
      logger.warn 'offset longer than freq'
    Game.time % f is offset


module.exports = {
  priority,
  freq,
  onFreq,
}
