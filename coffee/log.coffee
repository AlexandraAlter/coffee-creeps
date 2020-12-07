'use strict'


class Level
  @toString: ->
    "[class #{@name}]"

  constructor: (@name, @value) ->

  [Symbol.toPrimitive]: (hint) ->
    if hint is 'number' then return @value
    if hint is 'string' then return @name
    return @name

  toString: ->
    "[#{@constructor.name}]"


levels = {}

levels.TRACE = new Level 'trace', 1
levels.INFO  = new Level 'info',  2
levels.WARN  = new Level 'warn',  3
levels.ERROR = new Level 'error', 4
levels.FATAL = new Level 'fatal', 5

do -> levels[o.value] = o for n, o of levels


fmt = (strings, exps...) ->
  ->
    strings.reduce (acc, text, i) ->
      val = exps[i - 1]
      if val?
        val = val.toString()
      acc + val + text


class Logger
  @toString: ->
    "[class #{@name}]"

  Object.defineProperty @prototype, 'level',
    get: getLevel = -> @_level ? @?.parent?.level

  constructor: (@name, opts) ->
    {level: @_level, @parent} = opts
    throw Error 'invalid level' if @level not instanceof Level

  log: (prefix, str, opts) ->
    if typeof str is 'function'
      str = str()
    console.log('[' + @name + ']', prefix, str)
    return

  debug: (str, opts) ->
    @log('debug:', str, opts)
    return

  report: (report) ->
    @log('report:', report.toString(), null)
    return

  trace: (str, opts) ->
    if @level <= levels.TRACE
      @log('trace:', str, opts)
    return

  info: (str, opts) ->
    if @level <= levels.INFO
      @log('info:', str, opts)
    return

  warn: (str, opts) ->
    if @level <= levels.WARN
      @log('warn:', str, opts)
    return

  error: (str, opts) ->
    if @level <= levels.ERROR
      @log('error:', str, opts)
    return

  fatal: (str, opts) ->
    if @level <= levels.FATAL
      @log('fatal:', str, opts)
    return

  setLevel: (level) ->
    if @level isnt level
      @_level = level
      @info "logging at level #{@level.name}"
    return

  toString: ->
    "[#{@constructor.name} #{@name} at #{@level}#{
    (" inheriting #{@parent.name}" if @parent?) ? ''}]"


delete Memory.logLevel if typeof Memory.logLevel isnt 'number'
Memory.logLevel ?= levels.INFO.value
globalLogger = new Logger 'global', level: levels[Memory.logLevel]
loggers = new Set
loggers.add globalLogger


setGlobalLevel = (level) ->
  throw Error 'invalid level' if level not instanceof Level
  Memory.logLevel = level.value
  globalLogger.info "globally logging at level #{level.name}"
  return


getLogger = (name, level = null, parent = null) ->
  throw Error 'invalid name' if not name?
  throw Error 'invalid level' if level? and (level not instanceof Level)
  throw Error 'invalid parent' if parent? and (parent not instanceof Logger)
  for l from loggers.values()
    if l.name is name
      return l
  l = new Logger name, level: level, parent: parent ? globalLogger
  loggers.add l
  return l


module.exports = {
  Level
  levels...
  fmt
  Logger
  globalLogger
  setGlobalLevel
  getLogger
}
