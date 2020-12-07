'use strict'

log = require 'log'

logger = log.getLogger 'freq'

freq = {}


logger.info 'reloading'
firstLoadTime = Game.time


freq.EVERY = 1
freq.E_OTHER = 2
freq.SOME = 5
freq.OCC = 10
freq.RARELY = 200
freq.V_RARELY = 500
freq.RELOAD = Symbol('reload')
freq.SAFETY = Symbol('safety')
freq.DEBUG = Symbol('debug')
freq.TEST = Symbol('test')


safety = on
debug = on
test = on


freq.is = (fq, offset = 0) ->
  if typeof fq is 'number'
    if safety and offset >= fq
      logger.warn 'offset longer than freq'
    Game.time % fq is offset
  else if fq is freq.RELOAD
    Game.time is firstLoadTime
  else if fq is freq.SAFETY
    safety
  else if fq is freq.DEBUG
    debug
  else if fq is freq.TEST
    test
  else
    throw new Error 'invalid frequency'


freq.on = (fq, offset = 0, func) ->
  if freq.is fq, offset
    func()


freq.onEither = (fq1, fq2, offset = 0, func) ->
  if (freq.is fq1, offset) or (freq.is fq2, offset)
    func()


# (offset, func)
freq.onEvery =      freq.on.bind null, freq.EVERY
freq.onEveryOther = freq.on.bind null, freq.E_OTHER
freq.onSome =       freq.on.bind null, freq.SOME
freq.onOccasion =   freq.on.bind null, freq.OCC
freq.onRare =       freq.on.bind null, freq.RARELY
freq.onVRare =      freq.on.bind null, freq.V_RARELY
# (func)
freq.onReload = freq.on.bind null, freq.RELOAD, 0
freq.onSafety = freq.on.bind null, freq.SAFETY, 0
freq.onDebug =  freq.on.bind null, freq.DEBUG, 0
freq.onTest =   freq.on.bind null, freq.TEST, 0

# (offset, func)
freq.onSomeOrReload =     freq.onEither.bind null, freq.SOME, freq.RELOAD
freq.onOccasionOrReload = freq.onEither.bind null, freq.OCC, freq.RELOAD
freq.onRareOrReload =     freq.onEither.bind null, freq.RARELY, freq.RELOAD
freq.onVRareOrReload =    freq.onEither.bind null, freq.V_RARELY, freq.RELOAD


module.exports = freq
