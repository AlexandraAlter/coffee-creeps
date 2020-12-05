'use strict'

base = require 'base'
_ = require 'lodash'


class Level extends base.Pretty
  constructor: (@name, @value) ->
    super()
  [Symbol.toPrimitive]: (hint) ->
    if hint is 'number' then return @value
    if hint is 'string' then return @name
    return @value

TRACE = new Level 'trace', 1
INFO  = new Level 'info',  2
WARN  = new Level 'warn',  3
ERROR = new Level 'error', 4
FATAL = new Level 'fatal', 5


fmt = (strings, exps...) ->
  ->
    strings.reduce (acc, text, i) ->
      val = exps[i - 1]
      if val?
        val = val.toString()
      acc + val + text


class Logger extends base.Pretty
  constructor: (@name, opts) ->
    super()
    {@level, @parent} = opts

  log: (prefix, str, opts) ->
    if typeof str is 'function'
      str = str()
    console.log('[' + @name + ']', prefix, str)

  debug: (str, opts) ->
    @log('debug:', str, opts)

  trace: (str, opts) ->
    if @level <= TRACE
      @log('trace:', str, opts)

  info: (str, opts) ->
    if @level <= INFO
      @log('info:', str, opts)

  warn: (str, opts) ->
    if @level <= WARN
      @log('warn:', str, opts)

  error: (str, opts) ->
    if @level <= ERROR
      @log('error:', str, opts)

  fatal: (str, opts) ->
    if @level <= FATAL
      @log('fatal:', str, opts)

  setLevel: (level) ->
    if @level isnt level
      @level = level
      @info "logging at level #{@level.name}"


Memory.logLevel ?= INFO

globalLogger = new Logger 'global', level: Memory.logLevel

loggers = new WeakSet


getLogger = (name, parent = null) ->
  for l in loggers
    if l.name is name
      return l
  l = new Logger name, {parent: parent ? globalLogger}
  loggers.add l
  return l


module.exports = {
  Level, TRACE, INFO, WARN, ERROR, FATAL
  fmt
  Logger, globalLogger, loggers
  getLogger
}
