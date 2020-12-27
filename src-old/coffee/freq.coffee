'use strict'

log = require 'log'

logger = log.getLogger 'freq'


EVERY = 1
E_OTHER = 2
SOME = 5
OCC = 10
RARELY = 200
V_RARELY = 500
RELOAD = Symbol('reload')
SAFETY = Symbol('safety')
DEBUG = Symbol('debug')
TEST = Symbol('test')


safety = on
debug = on
test = on
reloading = on


freqIs = (fq, offset = 0) ->
  if typeof fq is 'number'
    if safety and offset >= fq
      logger.warn 'offset longer than freq'
    Game.time % fq is offset
  else if fq is RELOAD
    reloading
  else if fq is SAFETY
    safety
  else if fq is DEBUG
    debug
  else if fq is TEST
    test
  else
    throw new Error 'invalid frequency'


freqOn = (fq, offset = 0, func) ->
  if freqIs fq, offset
    func()


freqOnEither = (fq1, fq2, offset = 0, func) ->
  if (freqIs fq1, offset) or (freqIs fq2, offset)
    func()


# (offset, func)
onEvery =      freqOn.bind null, EVERY
onEveryOther = freqOn.bind null, E_OTHER
onSome =       freqOn.bind null, SOME
onOccasion =   freqOn.bind null, OCC
onRare =       freqOn.bind null, RARELY
onVRare =      freqOn.bind null, V_RARELY
# (func)
onReload = freqOn.bind null, RELOAD, 0
onSafety = freqOn.bind null, SAFETY, 0
onDebug =  freqOn.bind null, DEBUG, 0
onTest =   freqOn.bind null, TEST, 0

# (offset, func)
onSomeOrReload =     freqOnEither.bind null, SOME, RELOAD
onOccasionOrReload = freqOnEither.bind null, OCC, RELOAD
onRareOrReload =     freqOnEither.bind null, RARELY, RELOAD
onVRareOrReload =    freqOnEither.bind null, V_RARELY, RELOAD

reloadDone = -> reloading = off


module.exports = {
  EVERY, E_OTHER, SOME, OCC, RARELY, V_RARELY
  RELOAD, SAFETY, DEBUG, TEST
  safety, debug, test, reloading
  is: freqIs
  on: freqOn
  onEither: freqOnEither
  onEvery, onEveryOther, onSome, onOccasion, onRare, onVRare
  onReload, onSafety, onDebug, onTest
  onSomeOrReload
  onOccasionOrReload
  onRareOrReload
  onVRareOrReload
  reloadDone
}
