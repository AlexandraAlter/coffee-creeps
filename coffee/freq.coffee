'use strict'

logger = require 'logger'


freq = {}


freq.EVERY = 1
freq.E_OTHER = 2
freq.SOME = 5
freq.OCC = 10
freq.RARELY = 200
freq.V_RARELY = 500
freq.RELOAD = Symbol('reload')
freq.SAFETY = Symbol('safety')
freq.DEBUG = Symbol('debug')


logger.info 'reloading'
firstLoadTime = Game.time

safety = on
debug = on


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
  else
    throw new Error 'invalid frequency'


freq.on = (fq, offset = 0, func) ->
  if typeof offset is 'function'
    func = offset
    offset = 0
  if freq.is fq, offset
    func()


freq.onEither = (fq1, fq2, offset = 0, func) ->
  if (freq.is fq1, offset) or (freq.is fq2, offset)
    func()


freq.onEvery = (offset = 0, func) -> freq.on freq.EVERY, offset, func
freq.onEveryOther = (offset = 0, func) -> freq.on freq.E_OTHER, offset, func
freq.onSome = (offset = 0, func) -> freq.on freq.SOME, offset, func
freq.onOccasion = (offset = 0, func) -> freq.on freq.OCC, offset, func
freq.onRare = (offset = 0, func) -> freq.on freq.RARELY, offset, func
freq.onVRare = (offset = 0, func) -> freq.on freq.V_RARELY, offset, func
freq.onReload = (func) -> freq.on freq.RELOAD, 0, func
freq.onSafety = (func) -> freq.on freq.SAFETY, 0, func
freq.onDebug = (func) -> freq.on freq.DEBUG, 0, func

freq.onSomeOrReload = (offset = 0, func) ->
  freq.onEither freq.SOME, freq.RELOAD, offset, func
freq.onOccasionOrReload = (offset = 0, func) ->
  freq.onEither freq.OCC, freq.RELOAD, offset, func
freq.onRareOrReload = (offset = 0, func) ->
  freq.onEither freq.RARELY, freq.RELOAD, offset, func
freq.onVRareOrReload = (offset = 0, func) ->
  freq.onEither freq.V_RARELY, freq.RELOAD, offset, func


module.exports = freq
