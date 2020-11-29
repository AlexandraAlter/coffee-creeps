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

  log: (prefix, str, opts) ->
    indent = @indent + (opts? and opts.indent? and opts.indent or 0)
    if typeof str is 'function'
      str = str()
    console.log('|-'.repeat(indent) + prefix, str)

  fmt: (strings, exps...) ->
    ->
      strings.reduce (acc, text, i) ->
        acc + exps[i - 1].toString() + text

  debug: (str, opts) ->
    @log('debug:', str, opts)

  trace: (str, opts) ->
    if @level <= levels.TRACE
      @log('trace:', str, opts)

  info: (str, opts) ->
    if @level <= levels.INFO
      @log('info:', str, opts)

  warn: (str, opts) ->
    if @level <= levels.WARN
      @log('warn:', str, opts)

  error: (str, opts) ->
    if @level <= levels.ERROR
      @log('error:', str, opts)

  fatal: (str, opts) ->
    if @level <= levels.FATAL
      @log('fatal:', str, opts)


globalLogger = new Logger {}

log = (prefix, str, opts) -> globalLogger.log prefix, str, opts
fmt = (strings, exps...) -> globalLogger.fmt strings, exps...
debug = (str, opts) -> globalLogger.debug str, opts
trace = (str, opts) -> globalLogger.trace str, opts
info = (str, opts) -> globalLogger.info str, opts
warn = (str, opts) -> globalLogger.warn str, opts
error = (str, opts) -> globalLogger.error str, opts
fatal = (str, opts) -> globalLogger.fatal str, opts


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
    info "logging at level #{_.findKey levels, (v) -> v is level}"


if not Memory.logLevel?
  Memory.logLevel = levels.INFO

setLevel Memory.logLevel


module.exports = {
  levels,
  log, fmt, debug,
  trace, info, warn, error, fatal,
  withIndent, resetIndent,
  setLevel
}

