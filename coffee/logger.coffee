'use strict'

_ = require 'lodash'

levels =
  TRACE: 1
  INFO: 2
  WARN: 3
  ERROR: 4
  FATAL: 5


class Logger
  constructor: (opts) ->
    {@level = Memory.logLevel, @indent = 0} = opts

  log: (prefix, strs..., opts) ->
    if typeof opts isnt 'object'
      strs = [strs..., opts]
      opts = {}
    indent = @indent + (opts.indent or 0)
    console.log('|-'.repeat(indent) + prefix, strs...)

  debug: (strs..., opts) ->
    @log('debug:', strs..., opts)

  trace: (strs..., opts) ->
    if @level <= levels.TRACE
      @log('trace:', strs..., opts)

  info: (strs..., opts) ->
    if @level <= levels.INFO
      @log('info:', strs..., opts)

  warn: (strs..., opts) ->
    if @level <= levels.WARN
      @log('warn:', strs..., opts)

  error: (strs..., opts) ->
    if @level <= levels.ERROR
      @log('error:', strs..., opts)

  fatal: (strs..., opts) ->
    if @level <= levels.FATAL
      @log('fatal:', strs..., opts)


globalLogger = new Logger {}

log = (prefix, strs..., opts) -> globalLogger.log prefix, strs..., opts
debug = (strs..., opts) -> globalLogger.debug strs..., opts
trace = (strs..., opts) -> globalLogger.trace strs..., opts
info = (strs..., opts) -> globalLogger.info strs..., opts
warn = (strs..., opts) -> globalLogger.warn strs..., opts
error = (strs..., opts) -> globalLogger.error strs..., opts
fatal = (strs..., opts) -> globalLogger.fatal strs..., opts

withIndent = (func) ->
  globalLogger.indent++
  try
    res = func()
  finally
    globalLogger.indent--
  return res

resetIndent = ->
  if globalLogger.indent isnt 0
    globalLogger.indent = 0
    info 'reset indent'

setLevel = (level) ->
  if globalLogger.level isnt level
    globalLogger.level = level
    Memory.logLevel = level
    info 'logging at level', _.findKey levels, (v) -> v is level


if not Memory.logLevel?
  Memory.logLevel = levels.INFO

setLevel Memory.logLevel


module.exports = {
  levels,
  log, debug,
  trace, info, warn, error, fatal,
  withIndent, resetIndent,
  setLevel
}

